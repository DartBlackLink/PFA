"""Durable notification inbox and explicit ADMIN replanning of a running route."""
import uuid
from datetime import datetime, timedelta, timezone
from threading import BoundedSemaphore
from time import monotonic

from fastapi import APIRouter, Depends, HTTPException, Query
from pydantic import Field, field_validator, model_validator
from sqlalchemy import or_, select, text
from sqlalchemy.dialects.postgresql import insert
from sqlalchemy.orm import Session

from app.api.deps import get_current_user, require_roles
from app.api.routes.routes import accessible, owned_route, require_route_area, result
from app.db.session import get_db
from app.models.entities import (
    Incidente,
    LecturaNotificacion,
    Notificacion,
    Pedido,
    PlanOptimizacion,
    PoliticaTrafico,
    Repartidor,
    RevisionRuta,
    Ruta,
    RutaDetalle,
    Usuario,
    Vehiculo,
)
from app.schemas import ValidatedInput
from app.services.genetic import (
    Delivery,
    NoFeasiblePlan,
    Parameters,
    Rules,
    Team,
    evaluate_route,
    solve,
)
from app.services.matrix import road_matrix, road_shape
from app.services.operation_area import contains_geometry
from app.services.operation_area import validate_point
from app.services.optimization_context import valid_coordinates
from app.services.scheduling import schedule
from app.services.traffic import (
    LIMA,
    TrafficDurations,
    TrafficPolicyInput,
    digest,
    policy_snapshot,
)
from app.services.traffic_references import LOCAL_REFERENCES

router = APIRouter()
_slot = BoundedSemaphore(1)


@router.get('/traffic/references')
def local_traffic_references(user=Depends(require_roles('ADMIN'))):
    return LOCAL_REFERENCES


def now():
    return datetime.now(timezone.utc)


def policy_lock(db, exclusive=False):
    function = 'pg_advisory_xact_lock' if exclusive else 'pg_advisory_xact_lock_shared'
    db.execute(text(f'SELECT {function}(7351007)'))


@router.get('/traffic')
def read_traffic(db: Session = Depends(get_db), user=Depends(require_roles('ADMIN'))):
    return policy_snapshot(db)


@router.put('/traffic')
def change_traffic(payload: TrafficPolicyInput, db: Session = Depends(get_db),
                   user=Depends(require_roles('ADMIN'))):
    policy_lock(db, exclusive=True)
    row = db.get(PoliticaTrafico, 1)
    if payload.revision != (row.revision if row else 0):
        raise HTTPException(409, 'La configuración cambió; vuelve a cargarla antes de guardar.')
    if row is None:
        row = PoliticaTrafico(politica_id=1, revision=0, reglas=[], usuario_id=user.usuario_id)
        db.add(row)
    row.revision += 1
    row.reglas = [r.model_dump() for r in payload.reglas]
    row.actualizado_en = now()
    row.usuario_id = user.usuario_id
    db.commit()
    return policy_snapshot(db)


def notification_query(user):
    return select(Notificacion).where(or_(Notificacion.usuario_id == user.usuario_id,
        (Notificacion.usuario_id.is_(None)) & (Notificacion.rol == user.rol)))


@router.get('/notifications')
def notifications(limit: int = Query(100, ge=1, le=100), db: Session = Depends(get_db),
                  user=Depends(get_current_user)):
    rows = list(db.scalars(notification_query(user).order_by(Notificacion.creado_en.desc()).limit(limit)))
    read = set(db.scalars(select(LecturaNotificacion.notificacion_id).where(
        LecturaNotificacion.usuario_id == user.usuario_id,
        LecturaNotificacion.notificacion_id.in_([r.notificacion_id for r in rows]))))
    return [{'id': str(r.notificacion_id), 'ruta_id': str(r.ruta_id), 'tipo': r.tipo,
             'referencia_id': str(r.referencia_id), 'creado_en': r.creado_en,
             'leida': r.notificacion_id in read} for r in rows]


@router.post('/notifications/{identifier}/read')
def read_notification(identifier: uuid.UUID, db: Session = Depends(get_db), user=Depends(get_current_user)):
    if db.scalar(notification_query(user).where(Notificacion.notificacion_id == identifier)) is None:
        raise HTTPException(404, 'Notificación no encontrada.')
    db.execute(insert(LecturaNotificacion).values(notificacion_id=identifier,
        usuario_id=user.usuario_id, leido_en=now()).on_conflict_do_nothing())
    db.commit()
    return {'leida': True}


class ReplanInput(ValidatedInput):
    evento_id: uuid.UUID
    version: int = Field(ge=1)
    latitud: float = Field(ge=-90, le=90, allow_inf_nan=False)
    longitud: float = Field(ge=-180, le=180, allow_inf_nan=False)
    ubicacion_en: datetime
    motivo: str = Field(min_length=10, max_length=500)

    @model_validator(mode='after')
    def local_position(self):
        validate_point(self.latitud, self.longitud)
        return self

    @field_validator('ubicacion_en')
    @classmethod
    def aware_location(cls, value):
        if value.utcoffset() is None:
            raise ValueError('La ubicación necesita fecha con zona horaria')
        return value

    @field_validator('motivo')
    @classmethod
    def clean_reason(cls, value):
        value = value.strip()
        if len(value) < 10:
            raise ValueError('Describe el motivo con al menos diez caracteres')
        return value


def route_snapshot(route, db):
    details = list(db.scalars(select(RutaDetalle).where(RutaDetalle.ruta_id == route.ruta_id)
        .order_by(RutaDetalle.secuencia)))
    orders = {row.pedido_id: row for row in db.scalars(select(Pedido).where(
        Pedido.pedido_id.in_([d.pedido_id for d in details])))}
    driver = db.get(Repartidor, route.repartidor_id)
    vehicle = db.get(Vehiculo, route.vehiculo_id)
    account = db.get(Usuario, driver.usuario_id)
    data = {
        'ruta': {c.name: getattr(route, c.name) for c in Ruta.__table__.columns},
        'detalles': [{c.name: getattr(d, c.name) for c in RutaDetalle.__table__.columns} for d in details],
        'pedidos': [{c.name: getattr(orders[d.pedido_id], c.name) for c in Pedido.__table__.columns} for d in details],
        'repartidor': {c.name: getattr(driver, c.name) for c in Repartidor.__table__.columns},
        'vehiculo': {c.name: getattr(vehicle, c.name) for c in Vehiculo.__table__.columns},
        'cuenta': [str(account.usuario_id), account.rol, account.estado],
        'trafico': policy_snapshot(db),
        'incidentes': [{c.name: getattr(i, c.name) for c in Incidente.__table__.columns}
            for i in db.scalars(select(Incidente).where(Incidente.ruta_id == route.ruta_id).order_by(Incidente.incidente_id))],
    }
    # JSON representation is also the immutable audit snapshot; never includes passwords.
    import json
    return json.loads(json.dumps(data, default=str)), details, orders, driver, vehicle


def revision_view(item):
    return {'revision_id': str(item.revision_id), 'ruta_id': str(item.ruta_id),
        'version_base': item.version_base, 'estado': item.estado, 'motivo': item.motivo,
        'creado_en': item.creado_en, 'vence_en': item.vence_en,
        'aprobado_en': item.aprobado_en, 'aprobado_por': str(item.aprobado_por) if item.aprobado_por else None,
        'recibido_en': item.recibido_en, 'propuesta': item.propuesta,
        'anterior': item.anterior['ruta']}


@router.get('/routes/{ruta_id}/revisions')
def revisions(ruta_id: uuid.UUID, db: Session = Depends(get_db), user=Depends(get_current_user)):
    if db.scalar(accessible(db, user).where(Ruta.ruta_id == ruta_id)) is None:
        raise HTTPException(404, 'Ruta no encontrada.')
    query = select(RevisionRuta).where(RevisionRuta.ruta_id == ruta_id)
    if user.rol != 'ADMIN':
        query = query.where(RevisionRuta.estado == 'APROBADA')
    return [revision_view(r) for r in db.scalars(query.order_by(RevisionRuta.creado_en.desc()).limit(50))]


def require_active(route, version):
    if route.estado != 'EN_CURSO' or route.version != version:
        raise HTTPException(409, 'La ruta cambió o no está en ejecución; vuelve a cargarla.')
    if route.version != route.version_recibida:
        raise HTTPException(409, 'Espera la confirmación de recepción antes de proponer otra versión.')


def build_proposal(route, payload, db):
    require_route_area(route, db)
    require_active(route, payload.version)
    instant = now()
    if not -30 <= (instant - payload.ubicacion_en).total_seconds() <= 300:
        raise HTTPException(422, 'Usa una ubicación del vehículo obtenida en los últimos cinco minutos.')
    snapshot, details, orders, driver, vehicle = route_snapshot(route, db)
    incidents = list(db.scalars(select(Incidente).where(Incidente.ruta_id == route.ruta_id,
        Incidente.resuelto_en.is_(None))))
    if not any(i.incidente_id == payload.evento_id for i in incidents):
        raise HTTPException(422, 'Selecciona una incidencia abierta de esta ruta.')
    if any(i.tipo == 'VIA_CERRADA' for i in incidents):
        raise HTTPException(422, 'OSRM actual no permite excluir la vía reportada. Se conserva la ruta; gestiona el cierre con un proveedor compatible.')
    affecting = [i for i in incidents if i.tipo in ('CONGESTION', 'ACCIDENTE', 'AVERIA')]
    if any(i.demora_min is None for i in affecting):
        raise HTTPException(422, 'Falta demora estimada de una incidencia activa. Registra un reporte completo o gestiona la incidencia.')
    pending = [d for d in details if d.estado_entrega != 'ENTREGADO']
    if not pending or any(orders[d.pedido_id].estado != 'ASIGNADO' for d in pending):
        raise HTTPException(409, 'No hay entregas pendientes coherentes para recalcular.')
    if driver.estado != 'ACTIVO' or vehicle.estado != 'ACTIVO' or snapshot['cuenta'][1:] != ['REPARTIDOR', 'ACTIVO']:
        raise HTTPException(422, 'El equipo debe seguir activo.')
    if driver.disponible_desde is None or driver.disponible_hasta is None:
        raise HTTPException(422, 'Falta el turno del repartidor.')
    local = instant.astimezone(LIMA)
    end = datetime.combine(local.date(), driver.disponible_hasta, LIMA)
    if not driver.disponible_desde <= local.time().replace(tzinfo=None) < driver.disponible_hasta:
        raise HTTPException(422, 'La hora actual queda fuera del turno.')
    if route.origen_latitud is None or route.origen_longitud is None or not route.iniciado_en:
        raise HTTPException(422, 'Falta origen o inicio real de la ruta vigente.')
    previous_plan = db.get(PlanOptimizacion, route.plan_optimizacion_id) if route.plan_optimizacion_id else None
    constraints = previous_plan.solicitud if previous_plan else {}
    rules = Rules(route.servicio_min_por_entrega or 5,
        constraints.get('jornada_max_min', 480), constraints.get('descanso_cada_min', 240),
        constraints.get('descanso_min', 30), constraints.get('regresar_al_origen', False))
    # The depot remains the original depot across successive revisions.
    first_revision = db.scalar(select(RevisionRuta).where(RevisionRuta.ruta_id == route.ruta_id,
        RevisionRuta.estado == 'APROBADA').order_by(RevisionRuta.version_base).limit(1))
    original = first_revision.anterior['ruta'] if first_revision else snapshot['ruta']
    depot = valid_coordinates(original['origen_latitud'], original['origen_longitud'])
    coordinates = [(payload.latitud, payload.longitud), depot]
    deliveries = []
    for detail in pending:
        order = orders[detail.pedido_id]
        deliveries.append(Delivery(str(order.pedido_id), len(coordinates), float(order.peso_kg),
            (order.ventana_inicio - instant).total_seconds() / 60,
            (order.ventana_fin - instant).total_seconds() / 60))
        coordinates.append(valid_coordinates(order.latitud, order.longitud))
    used = max(0, (instant - route.iniciado_en).total_seconds() / 60)
    team = Team('0', 0, float(vehicle.capacidad_kg), float(vehicle.consumo_km_l),
        float(vehicle.factor_emision_kg_km), 0, (end - instant).total_seconds() / 60,
        assigned_minutes=used, return_node=1, initial_driving=min(used, rules.break_after))
    deadline = monotonic() + 25
    distance, duration, provider = road_matrix(coordinates, deadline)
    duration = TrafficDurations(duration, coordinates, instant, snapshot['trafico'],
        delay=sum(i.demora_min or 0 for i in affecting))
    try:
        plan, statistics = solve(deliveries, [team], distance, duration, rules, Parameters(seconds=5))
    except (NoFeasiblePlan, ValueError) as error:
        raise HTTPException(422, 'No se encontró una alternativa factible con las ventanas, capacidad, turno y demoras actuales. La ruta vigente se conserva.') from error
    candidate = plan.routes[0]
    by_id = {d.identifier: d for d in deliveries}
    indices = [0] + [by_id[k].node for k in candidate.deliveries] + ([1] if rules.return_to_origin else [])
    geometry, legs = road_shape([coordinates[i] for i in indices], deadline)
    if not contains_geometry(geometry):
        raise HTTPException(422, "La alternativa vial sale de la zona operativa. Revisa la ubicación y los destinos.")
    final_distance = [row[:] for row in distance]
    final_duration = [row[:] for row in duration]
    for (a, b), (km, minutes) in zip(zip(indices, indices[1:]), legs):
        final_distance[a][b], final_duration[a][b] = km, minutes
    final_duration = duration.with_base(final_duration)
    checked = evaluate_route(team, [by_id[k] for k in candidate.deliveries], final_distance, final_duration, rules)
    if checked is None:
        raise HTTPException(422, 'El recorrido vial final incumple las restricciones. Se conserva la ruta vigente.')
    baseline = evaluate_route(team, deliveries, distance, duration, rules)
    schedule(db, driver, vehicle, instant, checked.end - len(pending) * rules.service,
        len(pending), rules.service, route.ruta_id)
    statistics.update(provider)
    proposal = {
        'geometria': geometry, 'origen_latitud': payload.latitud, 'origen_longitud': payload.longitud,
        'ubicacion_en': payload.ubicacion_en.isoformat(), 'inicio_planificado': instant.isoformat(),
        'fin_planificado': (instant + timedelta(minutes=checked.end)).isoformat(),
        'distancia_km': checked.distance, 'tiempo_min': checked.travel,
        'combustible_l': checked.fuel, 'co2_kg': checked.carbon,
        'entregas': [{'pedido_id': s.delivery, 'eta': (instant + timedelta(minutes=s.service_start)).isoformat(),
            'fin_servicio': (instant + timedelta(minutes=s.finish)).isoformat()}
            for s in checked.stops],
        'trafico': snapshot['trafico'], 'demora_manual_min': duration.delay,
        'comparacion': {'base': 'Pendientes desde la misma ubicación y hora; no incluye trayecto ya completado',
            'vigente_factible': baseline is not None,
            'vigente_km': baseline.distance if baseline else None,
            'vigente_min': baseline.end if baseline else None,
            'alternativa_km': checked.distance, 'alternativa_min': checked.end,
            'diferencia_km': checked.distance - baseline.distance if baseline else None,
            'diferencia_min': checked.end - baseline.end if baseline else None,
            'ventanas_alternativa': 'Todas factibles bajo la estimación; no es puntualidad real',
            'retrasos_vigente': 'No calculables como ruta factible' if baseline is None else 'Sin incumplimientos estimados'},
        'estadisticas': statistics,
        'advertencia': 'Aproximación zonal/manual, no tráfico en vivo. La búsqueda no garantiza una mejora ni el óptimo global.',
    }
    return snapshot, proposal


@router.post('/routes/{ruta_id}/replan', status_code=201)
def replan(ruta_id: uuid.UUID, payload: ReplanInput, db: Session = Depends(get_db),
           user=Depends(require_roles('ADMIN'))):
    if not _slot.acquire(blocking=False):
        raise HTTPException(429, 'Hay una reoptimización en curso; reintenta.', headers={'Retry-After': '1'})
    try:
        route = db.get(Ruta, ruta_id)
        if route is None:
            raise HTTPException(404, 'Ruta no encontrada.')
        snapshot, proposal = build_proposal(route, payload, db)
        item = RevisionRuta(ruta_id=ruta_id, version_base=payload.version,
            autor_id=user.usuario_id, vence_en=now() + timedelta(minutes=2), motivo=payload.motivo,
            huella=digest(snapshot), anterior=snapshot, propuesta=proposal)
        db.add(item)
        db.commit()
        return revision_view(item)
    finally:
        _slot.release()


@router.post('/revisions/{identifier}/confirm')
def confirm_revision(identifier: uuid.UUID, db: Session = Depends(get_db), user=Depends(require_roles('ADMIN'))):
    current = db.get(RevisionRuta, identifier)
    if current is None:
        raise HTTPException(404, 'Propuesta no encontrada.')
    route = owned_route(db, user, current.ruta_id)
    item = db.scalar(select(RevisionRuta).where(RevisionRuta.revision_id == identifier)
        .with_for_update().execution_options(populate_existing=True))
    if item.estado == 'APROBADA':
        return revision_view(item)
    if item.estado != 'PROPUESTA' or item.vence_en < now():
        raise HTTPException(409, 'La propuesta fue rechazada o venció. Calcula otra.')
    require_active(route, item.version_base)
    policy_lock(db)
    snapshot, details, orders, driver, vehicle = route_snapshot(route, db)
    # Lock resources in the same order used by assignment; all delivery/report writes lock route.
    db.refresh(driver, with_for_update=True)
    db.refresh(vehicle, with_for_update=True)
    snapshot, details, orders, driver, vehicle = route_snapshot(route, db)
    if digest(snapshot) != item.huella:
        raise HTTPException(409, 'Cambió una entrega, incidencia, recurso o tráfico durante el cálculo. Recalcula.')
    proposal = item.propuesta
    start = datetime.fromisoformat(proposal['inicio_planificado'])
    # Do not send a two-minute-old ETA as a fresh departure estimate.
    if (now() - start).total_seconds() > 120:
        raise HTTPException(409, 'La estimación temporal venció. Recalcula desde la ubicación actual.')
    count = len(proposal['entregas'])
    total = (datetime.fromisoformat(proposal['fin_planificado']) - start).total_seconds() / 60
    schedule(db, driver, vehicle, start, total - count * (route.servicio_min_por_entrega or 5),
        count, route.servicio_min_por_entrega or 5, route.ruta_id)
    completed = [d for d in details if d.estado_entrega == 'ENTREGADO']
    pending = {str(d.pedido_id): d for d in details if d.estado_entrega != 'ENTREGADO'}
    if set(pending) != {d['pedido_id'] for d in proposal['entregas']}:
        raise HTTPException(409, 'Las entregas cambiaron; vuelve a calcular.')
    for sequence, delivery in enumerate(proposal['entregas'], len(completed) + 1):
        detail = pending[delivery['pedido_id']]
        detail.secuencia = sequence
        detail.eta = datetime.fromisoformat(delivery['eta'])
    for name in ['geometria', 'origen_latitud', 'origen_longitud', 'distancia_km', 'tiempo_min', 'combustible_l', 'co2_kg']:
        setattr(route, name, proposal[name])
    # Preserve actual initiation and the original planned departure for audit/SLA.
    route.fin_planificado = datetime.fromisoformat(proposal['fin_planificado'])
    route.version += 1
    item.estado, item.aprobado_por, item.aprobado_en = 'APROBADA', user.usuario_id, now()
    db.add(Notificacion(usuario_id=driver.usuario_id, ruta_id=route.ruta_id,
        tipo='NUEVA_VERSION', referencia_id=item.revision_id))
    db.commit()
    return revision_view(item)


@router.post('/revisions/{identifier}/reject')
def reject_revision(identifier: uuid.UUID, db: Session = Depends(get_db), user=Depends(require_roles('ADMIN'))):
    item = db.scalar(select(RevisionRuta).where(RevisionRuta.revision_id == identifier).with_for_update())
    if item is None:
        raise HTTPException(404, 'Propuesta no encontrada.')
    if item.estado == 'APROBADA':
        raise HTTPException(409, 'Una versión aprobada no puede rechazarse como propuesta.')
    item.estado = 'RECHAZADA'
    db.commit()
    return revision_view(item)


class VersionInput(ValidatedInput):
    version: int = Field(ge=1)


@router.post('/routes/{ruta_id}/ack')
def acknowledge_route(ruta_id: uuid.UUID, payload: VersionInput, db: Session = Depends(get_db),
                      user=Depends(require_roles('REPARTIDOR'))):
    route = owned_route(db, user, ruta_id)
    require_route_area(route, db)
    if route.version != payload.version:
        raise HTTPException(409, 'Se recibió otra versión. Carga el recorrido vigente.')
    route.version_recibida = payload.version
    item = db.scalar(select(RevisionRuta).where(RevisionRuta.ruta_id == ruta_id,
        RevisionRuta.estado == 'APROBADA', RevisionRuta.version_base == payload.version - 1))
    if item and item.recibido_en is None:
        item.recibido_en = now()
        db.add(Notificacion(rol='ADMIN', ruta_id=ruta_id, tipo='VERSION_RECIBIDA', referencia_id=item.revision_id))
    db.commit()
    return result(route, db)


class ResolutionInput(ValidatedInput):
    resolucion: str = Field(min_length=10, max_length=1000)

    @field_validator('resolucion')
    @classmethod
    def clean_resolution(cls, value):
        if len(value.strip()) < 10:
            raise ValueError('Describe la gestión realizada')
        return value.strip()


@router.post('/incidents/{identifier}/resolve')
def resolve_incident(identifier: uuid.UUID, payload: ResolutionInput, db: Session = Depends(get_db),
                     user=Depends(require_roles('ADMIN'))):
    item = db.get(Incidente, identifier)
    if item is None:
        raise HTTPException(404, 'Incidencia no encontrada.')
    owned_route(db, user, item.ruta_id)
    db.refresh(item)
    if item.resuelto_en is None:
        item.resuelto_en, item.resolucion = now(), payload.resolucion
    elif item.resolucion != payload.resolucion:
        raise HTTPException(409, 'El reporte ya tiene una resolución registrada.')
    db.commit()
    return {'evento_id': str(item.incidente_id), 'resuelto_en': item.resuelto_en, 'resolucion': item.resolucion}
