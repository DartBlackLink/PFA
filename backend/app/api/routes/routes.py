import uuid
from fastapi import APIRouter,Depends,HTTPException,Query
from sqlalchemy import select
from sqlalchemy.orm import Session
from app.db.session import get_db
from app.models.entities import Ruta,Repartidor,Usuario,Vehiculo,Pedido,RutaDetalle,Cliente
from app.api.deps import get_current_user,require_roles
from app.schemas import RutaCreate,RutaRead,RutaHorario
from app.services.routing import compute_route
from app.services.scheduling import schedule
router=APIRouter()

def accessible(db,user):
    query=select(Ruta)
    if user.rol=="REPARTIDOR":query=query.join(Repartidor,Repartidor.repartidor_id==Ruta.repartidor_id).where(Repartidor.usuario_id==user.usuario_id)
    return query

def result(route,db):
    data={c.name:getattr(route,c.name) for c in Ruta.__table__.columns}
    driver=db.get(Repartidor,route.repartidor_id);vehicle=db.get(Vehiculo,route.vehiculo_id)
    data["repartidor_nombre"]=driver.nombre if driver else None;data["vehiculo_placa"]=vehicle.placa if vehicle else None
    rows=db.execute(select(RutaDetalle,Pedido,Cliente.nombre).join(Pedido,Pedido.pedido_id==RutaDetalle.pedido_id).join(Cliente,Cliente.cliente_id==Pedido.cliente_id).where(RutaDetalle.ruta_id==route.ruta_id).order_by(RutaDetalle.secuencia)).all()
    data["entregas"]=[dict(pedido_id=str(order.pedido_id),cliente=client,direccion=order.direccion,punto_referencia=order.punto_referencia,latitud=float(order.latitud) if order.latitud is not None else None,longitud=float(order.longitud) if order.longitud is not None else None,peso_kg=float(order.peso_kg),prioridad=order.prioridad,tipo_producto=order.tipo_producto,ventana_inicio=order.ventana_inicio.isoformat(),ventana_fin=order.ventana_fin.isoformat(),secuencia=detail.secuencia,estado_entrega=detail.estado_entrega) for detail,order,client in rows]
    return data

@router.get("/",response_model=list[RutaRead])
def read_rutas(skip:int=Query(0,ge=0),limit:int=Query(100,ge=1,le=1000),db:Session=Depends(get_db),user:Usuario=Depends(get_current_user)):
    return [result(r,db) for r in db.scalars(accessible(db,user).order_by(Ruta.creado_en.desc()).offset(skip).limit(limit))]

@router.get("/{ruta_id}",response_model=RutaRead)
def read_route(ruta_id:uuid.UUID,db:Session=Depends(get_db),user:Usuario=Depends(get_current_user)):
    route=db.scalar(accessible(db,user).where(Ruta.ruta_id==ruta_id))
    if not route:raise HTTPException(404,"Ruta no encontrada.")
    return result(route,db)

@router.post("/",response_model=RutaRead,status_code=201)
def assign(payload:RutaCreate,db:Session=Depends(get_db),user:Usuario=Depends(require_roles("ADMIN"))):
    # Lock resources and orders in a stable order; parallel assignments cannot duplicate them.
    driver=db.scalar(select(Repartidor).where(Repartidor.repartidor_id==payload.repartidor_id).with_for_update())
    vehicle=db.scalar(select(Vehiculo).where(Vehiculo.vehiculo_id==payload.vehiculo_id).with_for_update())
    if not driver or not vehicle:raise HTTPException(422,"Repartidor o vehículo no encontrado.")
    account=db.get(Usuario,driver.usuario_id)
    if driver.estado!="ACTIVO" or not account or account.estado!="ACTIVO" or vehicle.estado!="ACTIVO":raise HTTPException(422,"Selecciona recursos activos.")
    if driver.origen_latitud is None or driver.origen_longitud is None:raise HTTPException(422,"Completa el punto de partida del repartidor.")
    orders=db.scalars(select(Pedido).where(Pedido.pedido_id.in_(payload.pedidos)).order_by(Pedido.pedido_id).with_for_update()).all()
    if len(orders)!=len(payload.pedidos):raise HTTPException(422,"Pedido no encontrado.")
    by_id={o.pedido_id:o for o in orders};ordered=[by_id[k] for k in payload.pedidos]
    if any(o.estado!="PENDIENTE" for o in ordered):raise HTTPException(409,"Algún pedido ya fue asignado o no está pendiente.")
    if db.scalar(select(RutaDetalle).where(RutaDetalle.pedido_id.in_(payload.pedidos)).limit(1)):raise HTTPException(409,"Un pedido ya tiene una asignación.")
    if any(o.latitud is None or o.longitud is None for o in ordered):raise HTTPException(422,"Completa las coordenadas de entrega de todos los pedidos.")
    if sum(o.peso_kg for o in ordered)>vehicle.capacidad_kg:raise HTTPException(422,"El peso supera la capacidad del vehículo.")
    points=[(float(driver.origen_latitud),float(driver.origen_longitud))]+[(float(o.latitud),float(o.longitud)) for o in ordered]
    geometry,distance,duration=compute_route(points)
    start,end=schedule(db,driver,vehicle,payload.inicio_planificado,duration,len(ordered),payload.servicio_min_por_entrega)
    route=Ruta(inicio_planificado=start,fin_planificado=end,servicio_min_por_entrega=payload.servicio_min_por_entrega,vehiculo_id=vehicle.vehiculo_id,repartidor_id=driver.repartidor_id,algoritmo="ASIGNACION_MANUAL_OSRM",estado="PLANIFICADA",origen_latitud=driver.origen_latitud,origen_longitud=driver.origen_longitud,geometria=geometry,distancia_km=distance,tiempo_min=duration)
    db.add(route);db.flush()
    for index,order in enumerate(ordered,1):
        db.add(RutaDetalle(ruta_id=route.ruta_id,pedido_id=order.pedido_id,secuencia=index));order.estado="ASIGNADO"
    db.commit();db.refresh(route)
    return result(route,db)


@router.put("/{ruta_id}/horario", response_model=RutaRead)
def change_schedule(ruta_id:uuid.UUID,payload:RutaHorario,db:Session=Depends(get_db),user:Usuario=Depends(require_roles("ADMIN"))):
    # Same resource lock order as assignment: driver, vehicle, then route.
    current=db.get(Ruta,ruta_id)
    if not current:raise HTTPException(404,"Ruta no encontrada.")
    driver=db.scalar(select(Repartidor).where(Repartidor.repartidor_id==current.repartidor_id).with_for_update())
    vehicle=db.scalar(select(Vehiculo).where(Vehiculo.vehiculo_id==current.vehiculo_id).with_for_update())
    route=db.scalar(select(Ruta).where(Ruta.ruta_id==ruta_id).with_for_update().execution_options(populate_existing=True))
    if route.estado!="PLANIFICADA":raise HTTPException(409,"Solo se modifica el horario de rutas planificadas.")
    account=db.get(Usuario,driver.usuario_id)
    if driver.estado!="ACTIVO" or vehicle.estado!="ACTIVO" or not account or account.estado!="ACTIVO":raise HTTPException(422,"Selecciona recursos activos.")
    if route.tiempo_min is None:raise HTTPException(422,"La ruta no tiene duración vial estimada.")
    count=len(db.scalars(select(RutaDetalle).where(RutaDetalle.ruta_id==ruta_id)).all())
    if not count:raise HTTPException(422,"La ruta no tiene entregas.")
    start,end=schedule(db,driver,vehicle,payload.inicio_planificado,route.tiempo_min,count,payload.servicio_min_por_entrega,route.ruta_id)
    route.inicio_planificado=start;route.fin_planificado=end;route.servicio_min_por_entrega=payload.servicio_min_por_entrega
    db.commit();db.refresh(route)
    return result(route,db)
