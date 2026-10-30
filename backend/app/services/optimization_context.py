"""Read/lock the eligible snapshot once; no per-generation SQL queries."""

import hashlib
import json
import math
from datetime import datetime, time, timedelta, timezone

from fastapi import HTTPException
from sqlalchemy import or_, select

from app.models.entities import Pedido, Repartidor, Ruta, RutaDetalle, Usuario, Vehiculo
from app.services.genetic import Delivery, Rules, Team
from app.services.scheduling import ACTIVE, LIMA


def minute_offset(value, origin):
    return (value - origin).total_seconds() / 60


def valid_coordinates(latitude, longitude):
    if latitude is None or longitude is None:
        raise HTTPException(
            422, "Todos los orígenes y pedidos necesitan coordenadas confirmadas."
        )
    lat, lon = float(latitude), float(longitude)
    if (
        not math.isfinite(lat)
        or not math.isfinite(lon)
        or not -90 <= lat <= 90
        or not -180 <= lon <= 180
    ):
        raise HTTPException(
            422, "Hay coordenadas inválidas; corrígelas antes de planificar."
        )
    return lat, lon


def load_context(payload, db, lock=False):
    driver_ids = [team.repartidor_id for team in payload.equipos]
    vehicle_ids = [team.vehiculo_id for team in payload.equipos]
    drivers_query = (
        select(Repartidor, Usuario)
        .join(Usuario, Usuario.usuario_id == Repartidor.usuario_id)
        .where(Repartidor.repartidor_id.in_(driver_ids))
        .order_by(Repartidor.repartidor_id)
    )
    vehicles_query = (
        select(Vehiculo)
        .where(Vehiculo.vehiculo_id.in_(vehicle_ids))
        .order_by(Vehiculo.vehiculo_id)
    )
    orders_query = (
        select(Pedido)
        .where(Pedido.pedido_id.in_(payload.pedidos))
        .order_by(Pedido.pedido_id)
    )
    if lock:
        drivers_query = drivers_query.with_for_update()
        vehicles_query = vehicles_query.with_for_update()
        orders_query = orders_query.with_for_update()
    drivers = {
        driver.repartidor_id: (driver, user)
        for driver, user in db.execute(drivers_query)
    }
    vehicles = {vehicle.vehiculo_id: vehicle for vehicle in db.scalars(vehicles_query)}
    orders = {order.pedido_id: order for order in db.scalars(orders_query)}
    if (
        len(drivers) != len(driver_ids)
        or len(vehicles) != len(vehicle_ids)
        or len(orders) != len(payload.pedidos)
    ):
        raise HTTPException(422, "Hay pedidos, vehículos o repartidores inexistentes.")
    if any(order.estado != "PENDIENTE" for order in orders.values()):
        raise HTTPException(409, "Selecciona exclusivamente pedidos pendientes.")
    if db.scalar(
        select(RutaDetalle).where(RutaDetalle.pedido_id.in_(payload.pedidos)).limit(1)
    ):
        raise HTTPException(
            409, "Un pedido ya tiene una ruta; vuelve a cargar la lista."
        )
    start = payload.inicio_planificado.astimezone(timezone.utc)
    day = datetime.combine(start.astimezone(LIMA).date(), time.min, LIMA)
    busy = list(
        db.scalars(
            select(Ruta)
            .where(
                Ruta.estado.in_(ACTIVE),
                or_(
                    Ruta.repartidor_id.in_(driver_ids),
                    Ruta.vehiculo_id.in_(vehicle_ids),
                ),
                or_(
                    Ruta.inicio_planificado.is_(None),
                    Ruta.inicio_planificado < day + timedelta(days=1),
                ),
                or_(Ruta.fin_planificado.is_(None), Ruta.fin_planificado > day),
            )
            .order_by(Ruta.ruta_id)
        )
    )
    coordinates = []
    teams = []
    resource_snapshot = []
    for index, selection in enumerate(payload.equipos):
        driver, user = drivers[selection.repartidor_id]
        vehicle = vehicles[selection.vehiculo_id]
        if (
            driver.estado != "ACTIVO"
            or user.estado != "ACTIVO"
            or user.rol != "REPARTIDOR"
            or vehicle.estado != "ACTIVO"
        ):
            raise HTTPException(
                422, "Selecciona equipos con vehículo, repartidor y cuenta activos."
            )
        if (
            driver.origen_latitud is None
            or driver.origen_longitud is None
            or driver.disponible_desde is None
            or driver.disponible_hasta is None
        ):
            raise HTTPException(
                422, "Completa el origen y el turno de todos los repartidores."
            )
        relevant = [
            r
            for r in busy
            if r.repartidor_id == driver.repartidor_id
            or r.vehiculo_id == vehicle.vehiculo_id
        ]
        if any(
            r.inicio_planificado is None or r.fin_planificado is None for r in relevant
        ):
            raise HTTPException(
                409,
                "Regulariza el horario de las rutas antiguas del equipo antes de optimizar.",
            )
        shift_start = datetime.combine(day.date(), driver.disponible_desde, LIMA)
        shift_end = datetime.combine(day.date(), driver.disponible_hasta, LIMA)
        begin = max(0, minute_offset(shift_start, start))
        finish = minute_offset(shift_end, start)
        if finish <= begin:
            raise HTTPException(
                422, "La salida solicitada queda fuera del turno de un repartidor."
            )
        intervals = tuple(
            (
                minute_offset(r.inicio_planificado, start),
                minute_offset(r.fin_planificado, start),
            )
            for r in relevant
        )
        used = sum(
            (r.fin_planificado - r.inicio_planificado).total_seconds() / 60
            for r in busy
            if r.repartidor_id == driver.repartidor_id
        )
        teams.append(
            Team(
                str(index),
                index,
                float(vehicle.capacidad_kg),
                float(vehicle.consumo_km_l),
                float(vehicle.factor_emision_kg_km),
                begin,
                finish,
                intervals,
                used,
            )
        )
        coordinates.append(
            valid_coordinates(driver.origen_latitud, driver.origen_longitud)
        )
        resource_snapshot.append(
            {
                "driver": str(driver.repartidor_id),
                "vehicle": str(vehicle.vehiculo_id),
                "state": (driver.estado, user.estado, user.rol, vehicle.estado),
                "origin": coordinates[-1],
                "shift": (
                    driver.disponible_desde.isoformat(),
                    driver.disponible_hasta.isoformat(),
                ),
                "capacity": str(vehicle.capacidad_kg),
                "consumption": str(vehicle.consumo_km_l),
                "emission": str(vehicle.factor_emision_kg_km),
            }
        )
    deliveries = []
    order_snapshot = []
    for identifier in payload.pedidos:
        order = orders[identifier]
        if order.latitud is None or order.longitud is None:
            raise HTTPException(
                422, "Todos los pedidos necesitan coordenadas confirmadas."
            )
        deliveries.append(
            Delivery(
                str(identifier),
                len(coordinates),
                float(order.peso_kg),
                minute_offset(order.ventana_inicio, start),
                minute_offset(order.ventana_fin, start),
            )
        )
        coordinates.append(valid_coordinates(order.latitud, order.longitud))
        order_snapshot.append(
            {
                "id": str(identifier),
                "coords": coordinates[-1],
                "weight": str(order.peso_kg),
                "window": (
                    order.ventana_inicio.isoformat(),
                    order.ventana_fin.isoformat(),
                ),
                "state": order.estado,
            }
        )
    snapshot = {
        "resources": resource_snapshot,
        "orders": order_snapshot,
        "busy": [
            (
                str(r.ruta_id),
                str(r.repartidor_id),
                str(r.vehiculo_id),
                r.inicio_planificado,
                r.fin_planificado,
                r.estado,
            )
            for r in busy
        ],
    }
    fingerprint = hashlib.sha256(
        json.dumps(snapshot, sort_keys=True, default=str).encode()
    ).hexdigest()
    rules = Rules(
        payload.servicio_min_por_entrega,
        payload.jornada_max_min,
        payload.descanso_cada_min,
        payload.descanso_min,
        payload.regresar_al_origen,
    )
    return {
        "orders": orders,
        "drivers": drivers,
        "vehicles": vehicles,
        "teams": teams,
        "deliveries": deliveries,
        "coordinates": coordinates,
        "fingerprint": fingerprint,
        "start": start,
        "rules": rules,
    }
