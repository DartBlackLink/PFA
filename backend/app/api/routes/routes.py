import uuid
from datetime import datetime, timezone
from typing import Literal

from fastapi import APIRouter, Depends, HTTPException, Query
from pydantic import Field, field_validator, model_validator
from sqlalchemy import select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.api.deps import get_current_user, require_roles
from app.db.session import get_db
from app.models.entities import (
    Cliente,
    Incidente,
    Notificacion,
    Pedido,
    Repartidor,
    Ruta,
    RutaDetalle,
    Usuario,
    Vehiculo,
)
from app.schemas import RutaCreate, RutaHorario, RutaRead, ValidatedInput
from app.services.operation_area import NAME, contains
from app.services.routing import compute_route
from app.services.scheduling import schedule

router = APIRouter()


def accessible(db, user):
    query = select(Ruta)
    if user.rol == "REPARTIDOR":
        query = query.join(
            Repartidor, Repartidor.repartidor_id == Ruta.repartidor_id
        ).where(Repartidor.usuario_id == user.usuario_id)
    return query


def _route_data(route, drivers, vehicles, details):
    data = {c.name: getattr(route, c.name) for c in Ruta.__table__.columns}
    driver = drivers.get(route.repartidor_id)
    vehicle = vehicles.get(route.vehiculo_id)
    data["repartidor_nombre"] = driver.nombre if driver else None
    data["vehiculo_placa"] = vehicle.placa if vehicle else None
    rows = details.get(route.ruta_id, [])
    known_points = [(route.origen_latitud, route.origen_longitud)] if route.origen_latitud is not None else []
    known_points.extend((order.latitud, order.longitud) for _, order, _ in rows if order.latitud is not None)
    known_points.extend((p[1], p[0]) for p in (route.geometria or {}).get('coordinates', []))
    data['ambito_operativo'] = NAME
    data['fuera_zona'] = any(not contains(lat, lon) for lat, lon in known_points)
    data["entregas"] = [
        dict(
            pedido_id=str(order.pedido_id),
            cliente=client,
            direccion=order.direccion,
            punto_referencia=order.punto_referencia,
            latitud=float(order.latitud) if order.latitud is not None else None,
            longitud=float(order.longitud) if order.longitud is not None else None,
            peso_kg=float(order.peso_kg),
            prioridad=order.prioridad,
            tipo_producto=order.tipo_producto,
            ventana_inicio=order.ventana_inicio.isoformat(),
            ventana_fin=order.ventana_fin.isoformat(),
            eta=detail.eta.isoformat() if detail.eta else None,
            secuencia=detail.secuencia,
            estado_entrega=detail.estado_entrega,
            entregado_en=detail.entregado_en.isoformat() if detail.entregado_en else None,
        )
        for detail, order, client in rows
    ]
    return data


def results(routes, db):
    """Three batch reads, independent of route count; caller enforces visibility."""
    routes = list(routes)
    if not routes:
        return []
    drivers = {
        row.repartidor_id: row
        for row in db.scalars(
            select(Repartidor).where(
                Repartidor.repartidor_id.in_({r.repartidor_id for r in routes})
            )
        )
    }
    vehicles = {
        row.vehiculo_id: row
        for row in db.scalars(
            select(Vehiculo).where(
                Vehiculo.vehiculo_id.in_({r.vehiculo_id for r in routes})
            )
        )
    }
    rows = db.execute(
        select(RutaDetalle, Pedido, Cliente.nombre)
        .join(Pedido, Pedido.pedido_id == RutaDetalle.pedido_id)
        .join(Cliente, Cliente.cliente_id == Pedido.cliente_id)
        .where(RutaDetalle.ruta_id.in_([r.ruta_id for r in routes]))
        .order_by(RutaDetalle.ruta_id, RutaDetalle.secuencia)
    ).all()
    details = {}
    for row in rows:
        details.setdefault(row[0].ruta_id, []).append(row)
    return [_route_data(route, drivers, vehicles, details) for route in routes]


def result(route, db):
    return results([route], db)[0]


@router.get("/", response_model=list[RutaRead])
def read_rutas(
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=1000),
    db: Session = Depends(get_db),
    user: Usuario = Depends(get_current_user),
):
    return results(
        db.scalars(
            accessible(db, user)
            .order_by(Ruta.creado_en.desc())
            .offset(skip)
            .limit(limit)
        ),
        db,
    )


@router.get("/{ruta_id}", response_model=RutaRead)
def read_route(
    ruta_id: uuid.UUID,
    db: Session = Depends(get_db),
    user: Usuario = Depends(get_current_user),
):
    route = db.scalar(accessible(db, user).where(Ruta.ruta_id == ruta_id))
    if not route:
        raise HTTPException(404, "Ruta no encontrada.")
    return result(route, db)


def owned_route(db, user, route_id):
    current = db.scalar(accessible(db, user).where(Ruta.ruta_id == route_id))
    if current is None:
        raise HTTPException(404, 'Ruta no encontrada.')
    db.scalar(select(Repartidor).where(Repartidor.repartidor_id == current.repartidor_id).with_for_update())
    db.scalar(select(Vehiculo).where(Vehiculo.vehiculo_id == current.vehiculo_id).with_for_update())
    route = db.scalar(accessible(db, user).where(Ruta.ruta_id == route_id).with_for_update(of=Ruta)
        .execution_options(populate_existing=True))
    if route is None:
        raise HTTPException(404, 'Ruta no encontrada.')
    return route


def require_route_area(route, db):
    if result(route, db)['fuera_zona']:
        raise HTTPException(409, 'Registro histórico fuera de Huancayo: consulta permitida, operación y recálculo deshabilitados.')


@router.post('/{ruta_id}/iniciar', response_model=RutaRead)
def start_route(ruta_id: uuid.UUID, db: Session = Depends(get_db),
                user: Usuario = Depends(require_roles('REPARTIDOR'))):
    route = owned_route(db, user, ruta_id)
    require_route_area(route, db)
    if route.estado == 'EN_CURSO':
        return result(route, db)
    if route.estado != 'PLANIFICADA':
        raise HTTPException(409, 'Solo puedes iniciar una ruta planificada.')
    if route.inicio_planificado is None or route.fin_planificado is None:
        raise HTTPException(409, 'Solicita al administrador completar el horario de esta ruta.')
    driver = db.scalar(select(Repartidor).where(Repartidor.repartidor_id == route.repartidor_id).with_for_update())
    vehicle = db.scalar(select(Vehiculo).where(Vehiculo.vehiculo_id == route.vehiculo_id).with_for_update())
    if driver.estado != 'ACTIVO' or vehicle.estado != 'ACTIVO':
        raise HTTPException(409, 'El repartidor y el vehículo deben estar activos.')
    if db.scalar(select(Ruta.ruta_id).where(Ruta.ruta_id != ruta_id, Ruta.estado.in_(('EN_CURSO','EN_RUTA')),
                  (Ruta.repartidor_id == route.repartidor_id) | (Ruta.vehiculo_id == route.vehiculo_id))):
        raise HTTPException(409, 'El equipo ya tiene otra ruta en ejecución.')
    route.estado = 'EN_CURSO'
    route.iniciado_en = datetime.now(timezone.utc)
    # Explicit initiation from the courier app proves receipt of the initial plan.
    route.version_recibida = route.version
    db.commit()
    return result(route, db)


@router.post('/{ruta_id}/entregas/{pedido_id}/confirmar', response_model=RutaRead)
def complete_delivery(ruta_id: uuid.UUID, pedido_id: uuid.UUID, version: int | None = Query(None, ge=1),
                      db: Session = Depends(get_db), user: Usuario = Depends(require_roles('REPARTIDOR'))):
    route = owned_route(db, user, ruta_id)
    require_route_area(route, db)
    if route.version > 1 and (version != route.version or route.version_recibida != route.version):
        raise HTTPException(409, 'Recibe y confirma la versión vigente antes de continuar las entregas.')
    details = list(db.scalars(select(RutaDetalle).where(RutaDetalle.ruta_id == ruta_id)
                             .order_by(RutaDetalle.secuencia).with_for_update()))
    detail = next((row for row in details if row.pedido_id == pedido_id), None)
    if detail is None:
        raise HTTPException(404, 'Entrega no encontrada en esta ruta.')
    if detail.estado_entrega == 'ENTREGADO':
        return result(route, db)
    if route.estado != 'EN_CURSO':
        raise HTTPException(409, 'Inicia la ruta antes de confirmar una entrega.')
    if any(row.secuencia < detail.secuencia and row.estado_entrega != 'ENTREGADO' for row in details):
        raise HTTPException(409, 'Confirma primero la parada anterior para respetar la secuencia.')
    now = datetime.now(timezone.utc)
    detail.estado_entrega = 'ENTREGADO'
    detail.entregado_en = now
    detail.entregado_por = user.usuario_id
    db.get(Pedido, pedido_id).estado = 'ENTREGADO'
    if all(row.estado_entrega == 'ENTREGADO' for row in details):
        route.estado = 'FINALIZADA'
        route.finalizado_en = now
    db.commit()
    return result(route, db)


class IncidentInput(ValidatedInput):
    evento_id: uuid.UUID
    tipo: Literal['AVERIA', 'ACCIDENTE', 'ENTREGA_FALLIDA', 'OTRO', 'CONGESTION', 'VIA_CERRADA']
    descripcion: str = Field(min_length=10, max_length=1000)
    latitud: float | None = Field(None, ge=-90, le=90, allow_inf_nan=False)
    longitud: float | None = Field(None, ge=-180, le=180, allow_inf_nan=False)
    ocurrido_en: datetime | None = None
    demora_min: int | None = Field(None, ge=0, le=240)
    afectacion: Literal['BAJA', 'MEDIA', 'ALTA', 'NO_INDICADA'] = 'NO_INDICADA'

    @field_validator('latitud', 'longitud')
    @classmethod
    def coordinate_precision(cls, value):
        return round(value, 6) if value is not None else None

    @model_validator(mode='after')
    def valid_report(self):
        if (self.latitud is None) != (self.longitud is None):
            raise ValueError('Indica ambas coordenadas o ninguna')
        if self.latitud is not None and not contains(self.latitud, self.longitud):
            raise ValueError('La incidencia debe ubicarse dentro de Huancayo y sus alrededores habilitados.')
        if self.ocurrido_en is not None:
            if self.ocurrido_en.utcoffset() is None:
                raise ValueError('La hora del evento necesita zona horaria')
            age = (datetime.now(timezone.utc) - self.ocurrido_en).total_seconds()
            if not -60 <= age <= 86400:
                raise ValueError('El evento debe corresponder a las últimas 24 horas')
        return self

    @field_validator('descripcion')
    @classmethod
    def clean_description(cls, value):
        value = value.strip()
        if len(value) < 10:
            raise ValueError('Describe el incidente con al menos 10 caracteres')
        return value


def incident_view(item):
    return {'evento_id': str(item.incidente_id), 'tipo': item.tipo,
            'descripcion': item.descripcion, 'ocurrido_en': item.ocurrido_en.isoformat(),
            'ruta_id': str(item.ruta_id), 'repartidor_id': str(item.repartidor_id),
            'latitud': float(item.latitud) if item.latitud is not None else None,
            'longitud': float(item.longitud) if item.longitud is not None else None,
            'demora_min': item.demora_min, 'afectacion': item.afectacion,
            'fuente': 'REPORTE_MANUAL_REPARTIDOR',
            'resuelto_en': item.resuelto_en.isoformat() if item.resuelto_en else None,
            'resolucion': item.resolucion}


@router.get('/{ruta_id}/incidentes')
def read_incidents(ruta_id: uuid.UUID, db: Session = Depends(get_db),
                   user: Usuario = Depends(get_current_user)):
    if db.scalar(accessible(db, user).where(Ruta.ruta_id == ruta_id)) is None:
        raise HTTPException(404, 'Ruta no encontrada.')
    return [incident_view(row) for row in db.scalars(select(Incidente)
        .where(Incidente.ruta_id == ruta_id).order_by(Incidente.ocurrido_en))]


@router.post('/{ruta_id}/incidentes')
def report_incident(ruta_id: uuid.UUID, payload: IncidentInput, db: Session = Depends(get_db),
                    user: Usuario = Depends(require_roles('REPARTIDOR'))):
    route = owned_route(db, user, ruta_id)
    require_route_area(route, db)
    previous = db.get(Incidente, payload.evento_id)
    if previous:
        if (previous.ruta_id != ruta_id or previous.repartidor_id != route.repartidor_id
                or previous.tipo != payload.tipo or previous.descripcion != payload.descripcion
                or previous.demora_min != payload.demora_min or previous.afectacion != payload.afectacion
                or (float(previous.latitud) if previous.latitud is not None else None) != payload.latitud
                or (float(previous.longitud) if previous.longitud is not None else None) != payload.longitud
                or (payload.ocurrido_en is not None and previous.ocurrido_en != payload.ocurrido_en)):
            raise HTTPException(409, 'El identificador del evento ya fue utilizado.')
        return incident_view(previous)
    if route.estado != 'EN_CURSO':
        raise HTTPException(409, 'Reporta incidencias desde una ruta en ejecución.')
    item = Incidente(incidente_id=payload.evento_id, ruta_id=ruta_id,
                    repartidor_id=route.repartidor_id, tipo=payload.tipo, descripcion=payload.descripcion,
                    latitud=payload.latitud, longitud=payload.longitud, demora_min=payload.demora_min,
                    afectacion=payload.afectacion,
                    ocurrido_en=payload.ocurrido_en or datetime.now(timezone.utc))
    db.add(item)
    db.add(Notificacion(rol='ADMIN', ruta_id=ruta_id, tipo='INCIDENCIA', referencia_id=payload.evento_id))
    try:
        db.commit()
    except IntegrityError:
        db.rollback()
        raise HTTPException(409, 'El evento ya se registró; consulta el historial antes de reintentar.')
    return incident_view(item)


@router.post("/", response_model=RutaRead, status_code=201)
def assign(
    payload: RutaCreate,
    db: Session = Depends(get_db),
    user: Usuario = Depends(require_roles("ADMIN")),
):
    # Lock resources and orders in a stable order; parallel assignments cannot duplicate them.
    driver = db.scalar(
        select(Repartidor)
        .where(Repartidor.repartidor_id == payload.repartidor_id)
        .with_for_update()
    )
    vehicle = db.scalar(
        select(Vehiculo)
        .where(Vehiculo.vehiculo_id == payload.vehiculo_id)
        .with_for_update()
    )
    if not driver or not vehicle:
        raise HTTPException(422, "Repartidor o vehículo no encontrado.")
    account = db.get(Usuario, driver.usuario_id)
    if (
        driver.estado != "ACTIVO"
        or not account
        or account.estado != "ACTIVO"
        or vehicle.estado != "ACTIVO"
    ):
        raise HTTPException(422, "Selecciona recursos activos.")
    if driver.origen_latitud is None or driver.origen_longitud is None:
        raise HTTPException(422, "Completa el punto de partida del repartidor.")
    orders = db.scalars(
        select(Pedido)
        .where(Pedido.pedido_id.in_(payload.pedidos))
        .order_by(Pedido.pedido_id)
        .with_for_update()
    ).all()
    if len(orders) != len(payload.pedidos):
        raise HTTPException(422, "Pedido no encontrado.")
    by_id = {o.pedido_id: o for o in orders}
    ordered = [by_id[k] for k in payload.pedidos]
    if any(o.estado != "PENDIENTE" for o in ordered):
        raise HTTPException(409, "Algún pedido ya fue asignado o no está pendiente.")
    if db.scalar(
        select(RutaDetalle).where(RutaDetalle.pedido_id.in_(payload.pedidos)).limit(1)
    ):
        raise HTTPException(409, "Un pedido ya tiene una asignación.")
    if any(o.latitud is None or o.longitud is None for o in ordered):
        raise HTTPException(
            422, "Completa las coordenadas de entrega de todos los pedidos."
        )
    if sum(o.peso_kg for o in ordered) > vehicle.capacidad_kg:
        raise HTTPException(422, "El peso supera la capacidad del vehículo.")
    points = [(float(driver.origen_latitud), float(driver.origen_longitud))] + [
        (float(o.latitud), float(o.longitud)) for o in ordered
    ]
    if any(not contains(lat, lon) for lat, lon in points):
        raise HTTPException(422, 'El origen y las entregas deben pertenecer a Huancayo y sus alrededores habilitados.')
    geometry, distance, duration = compute_route(points)
    start, end = schedule(
        db,
        driver,
        vehicle,
        payload.inicio_planificado,
        duration,
        len(ordered),
        payload.servicio_min_por_entrega,
    )
    route = Ruta(
        inicio_planificado=start,
        fin_planificado=end,
        servicio_min_por_entrega=payload.servicio_min_por_entrega,
        vehiculo_id=vehicle.vehiculo_id,
        repartidor_id=driver.repartidor_id,
        algoritmo="ASIGNACION_MANUAL_OSRM",
        estado="PLANIFICADA",
        origen_latitud=driver.origen_latitud,
        origen_longitud=driver.origen_longitud,
        geometria=geometry,
        distancia_km=distance,
        tiempo_min=duration,
    )
    db.add(route)
    db.flush()
    for index, order in enumerate(ordered, 1):
        db.add(
            RutaDetalle(
                ruta_id=route.ruta_id, pedido_id=order.pedido_id, secuencia=index
            )
        )
        order.estado = "ASIGNADO"
    db.commit()
    db.refresh(route)
    return result(route, db)


@router.put("/{ruta_id}/horario", response_model=RutaRead)
def change_schedule(
    ruta_id: uuid.UUID,
    payload: RutaHorario,
    db: Session = Depends(get_db),
    user: Usuario = Depends(require_roles("ADMIN")),
):
    # Same resource lock order as assignment: driver, vehicle, then route.
    current = db.get(Ruta, ruta_id)
    if not current:
        raise HTTPException(404, "Ruta no encontrada.")
    driver = db.scalar(
        select(Repartidor)
        .where(Repartidor.repartidor_id == current.repartidor_id)
        .with_for_update()
    )
    vehicle = db.scalar(
        select(Vehiculo)
        .where(Vehiculo.vehiculo_id == current.vehiculo_id)
        .with_for_update()
    )
    route = db.scalar(
        select(Ruta)
        .where(Ruta.ruta_id == ruta_id)
        .with_for_update()
        .execution_options(populate_existing=True)
    )
    if route.estado != "PLANIFICADA":
        raise HTTPException(409, "Solo se modifica el horario de rutas planificadas.")
    require_route_area(route, db)
    account = db.get(Usuario, driver.usuario_id)
    if (
        driver.estado != "ACTIVO"
        or vehicle.estado != "ACTIVO"
        or not account
        or account.estado != "ACTIVO"
    ):
        raise HTTPException(422, "Selecciona recursos activos.")
    if route.tiempo_min is None:
        raise HTTPException(422, "La ruta no tiene duración vial estimada.")
    count = len(
        db.scalars(select(RutaDetalle).where(RutaDetalle.ruta_id == ruta_id)).all()
    )
    if not count:
        raise HTTPException(422, "La ruta no tiene entregas.")
    start, end = schedule(
        db,
        driver,
        vehicle,
        payload.inicio_planificado,
        route.tiempo_min,
        count,
        payload.servicio_min_por_entrega,
        route.ruta_id,
    )
    route.inicio_planificado = start
    route.fin_planificado = end
    route.servicio_min_por_entrega = payload.servicio_min_por_entrega
    db.commit()
    db.refresh(route)
    return result(route, db)
