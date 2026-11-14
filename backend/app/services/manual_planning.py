"""Validate a fixed order with the same hard constraints as the genetic engine."""

from datetime import datetime, timedelta

from fastapi import HTTPException

from app.services.genetic import Delivery, Rules, Team, evaluate_route
from app.services.scheduling import LIMA, schedule
from app.services.traffic import TrafficDurations, policy_snapshot


def evaluate_manual(db, driver, vehicle, orders, start, service, coordinates, legs, route_id=None, return_to_origin=False):
    if len(legs) != len(coordinates) - 1:
        raise HTTPException(503, "El proveedor no devolvió todos los tramos; no se asignó el pedido.")
    if driver.disponible_hasta is None or driver.disponible_desde is None:
        raise HTTPException(422, "Completa el turno del repartidor.")
    local = start.astimezone(LIMA)
    end = datetime.combine(local.date(), driver.disponible_hasta, LIMA)
    if not driver.disponible_desde <= local.time().replace(tzinfo=None) < driver.disponible_hasta:
        raise HTTPException(422, "La salida queda fuera del turno del repartidor.")
    size = len(orders) + 1
    distance = [[0.0] * size for _ in range(size)]
    duration = [[0.0] * size for _ in range(size)]
    for i, (km, minutes) in enumerate(legs):
        destination = i + 1 if i < len(orders) else 0
        distance[i][destination] = km
        duration[i][destination] = minutes
    traffic = TrafficDurations(duration, coordinates[:size], start, policy_snapshot(db))
    deliveries = [Delivery(str(order.pedido_id), i, float(order.peso_kg),
                          (order.ventana_inicio - start).total_seconds() / 60,
                          (order.ventana_fin - start).total_seconds() / 60)
                  for i, order in enumerate(orders, 1)]
    team = Team("manual", 0, float(vehicle.capacidad_kg), float(vehicle.consumo_km_l),
                float(vehicle.factor_emision_kg_km), 0, (end - start).total_seconds() / 60)
    candidate = evaluate_route(team, deliveries, distance, traffic, Rules(service=service, return_to_origin=return_to_origin))
    if candidate is None:
        raise HTTPException(422, "El orden manual no cumple ventanas completas, capacidad, turno, jornada o descansos. Cambia la salida/secuencia o utiliza la optimización.")
    start, end = schedule(db, driver, vehicle, start, candidate.end - len(orders) * service,
                          len(orders), service, route_id)
    etas = {stop.delivery: start + timedelta(minutes=stop.service_start) for stop in candidate.stops}
    return candidate, start, end, etas
