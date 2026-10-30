"""Operational schedule checks. America/Lima uses UTC-05:00 year-round."""

from datetime import datetime, timedelta, timezone

from fastapi import HTTPException
from sqlalchemy import or_, select

from app.models.entities import Ruta

LIMA = timezone(timedelta(hours=-5))
ACTIVE = ("PLANIFICADA", "EN_CURSO", "EN_RUTA")


def schedule(
    db,
    driver,
    vehicle,
    start,
    travel_minutes,
    deliveries,
    service_minutes,
    route_id=None,
):
    if driver.disponible_desde is None or driver.disponible_hasta is None:
        raise HTTPException(422, "Completa el inicio y fin del turno del repartidor.")
    start = start.astimezone(timezone.utc)
    end = start + timedelta(
        minutes=float(travel_minutes) + deliveries * service_minutes
    )
    if end <= start:
        raise HTTPException(422, "La duración total de la ruta debe ser mayor a cero.")
    local_start, local_end = start.astimezone(LIMA), end.astimezone(LIMA)
    shift_start = datetime.combine(local_start.date(), driver.disponible_desde, LIMA)
    shift_end = datetime.combine(local_start.date(), driver.disponible_hasta, LIMA)
    if local_start < shift_start or local_end > shift_end:
        raise HTTPException(
            422,
            f"La ruta ({local_start:%d/%m %H:%M}–{local_end:%H:%M}, hora de Lima) queda fuera del turno {driver.disponible_desde:%H:%M}–{driver.disponible_hasta:%H:%M}. Cambia la salida o el repartidor.",
        )
    query = select(Ruta).where(
        Ruta.estado.in_(ACTIVE),
        or_(
            Ruta.repartidor_id == driver.repartidor_id,
            Ruta.vehiculo_id == vehicle.vehiculo_id,
        ),
    )
    if route_id is not None:
        query = query.where(Ruta.ruta_id != route_id)
    for other in db.scalars(query):
        if other.inicio_planificado is None or other.fin_planificado is None:
            if route_id is None:
                raise HTTPException(
                    409,
                    "El equipo tiene una ruta anterior sin horario. Registra su horario desde Rutas antes de crear otra asignación.",
                )
            continue  # Regularizar una ruta antigua permite completar sucesivamente sus horarios.
        if start < other.fin_planificado and other.inicio_planificado < end:
            resource = (
                "repartidor"
                if other.repartidor_id == driver.repartidor_id
                else "vehículo"
            )
            a, b = (
                other.inicio_planificado.astimezone(LIMA),
                other.fin_planificado.astimezone(LIMA),
            )
            raise HTTPException(
                409,
                f"El {resource} ya tiene una ruta de {a:%d/%m/%Y %H:%M} a {b:%H:%M} (Lima). Elige otro horario o equipo.",
            )
    return start, end
