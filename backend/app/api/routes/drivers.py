import uuid
from fastapi import APIRouter,Depends,HTTPException,Query
from sqlalchemy import select,func
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session
from app.core.security import get_password_hash
from app.db.session import get_db
from app.models.entities import Repartidor,Usuario
from app.schemas import RepartidorCreate,RepartidorRead
from app.api.deps import get_current_user
router=APIRouter()

def result(item,db):
    data={c.name:getattr(item,c.name) for c in Repartidor.__table__.columns}
    user=db.get(Usuario,item.usuario_id);data["correo"]=user.email if user else None
    return data

@router.get("/me",response_model=RepartidorRead)
def my_profile(user:Usuario=Depends(get_current_user),db:Session=Depends(get_db)):
    item=db.scalar(select(Repartidor).where(Repartidor.usuario_id==user.usuario_id))
    if not item:raise HTTPException(404,"Aún no tienes un perfil de repartidor asignado.")
    return result(item,db)

@router.get("/",response_model=list[RepartidorRead])
def read_repartidores(skip:int=Query(0,ge=0),limit:int=Query(100,ge=1,le=1000),db:Session=Depends(get_db)):
    return [result(item,db) for item in db.scalars(select(Repartidor).order_by(Repartidor.nombre).offset(skip).limit(limit)).all()]

def save(payload,db,item=None):
    duplicate=select(Repartidor).where(Repartidor.dni==payload.dni)
    if item:duplicate=duplicate.where(Repartidor.repartidor_id!=item.repartidor_id)
    if db.scalar(duplicate):raise HTTPException(409,"El DNI ya está registrado.")
    if item:
        user=db.get(Usuario,item.usuario_id)
        if payload.usuario_id and payload.usuario_id!=item.usuario_id:raise HTTPException(422,"No puedes cambiar la identidad del perfil.")
    elif payload.usuario_id:
        user=db.get(Usuario,payload.usuario_id)
        if not user or user.rol!="REPARTIDOR":raise HTTPException(422,"Selecciona un usuario REPARTIDOR válido.")
        if db.scalar(select(Repartidor).where(Repartidor.usuario_id==user.usuario_id)):raise HTTPException(409,"El usuario ya tiene un perfil.")
    else:
        if not payload.correo or not payload.password:raise HTTPException(422,"Correo y contraseña inicial son obligatorios.")
        user=Usuario(email=payload.correo,password_hash=get_password_hash(payload.password),rol="REPARTIDOR",estado=payload.estado)
        db.add(user)
    if payload.correo:
        existing=db.scalar(select(Usuario).where(func.lower(Usuario.email)==payload.correo))
        if existing and existing.usuario_id!=user.usuario_id:raise HTTPException(409,"El correo ya está registrado.")
        user.email=payload.correo
    if payload.password:user.password_hash=get_password_hash(payload.password)
    user.estado=payload.estado
    if not item:
        try: db.flush()
        except IntegrityError:
            db.rollback();raise HTTPException(409,"El correo ya está registrado.")
        item=Repartidor(usuario_id=user.usuario_id)
    for k,v in payload.model_dump(exclude={"usuario_id","correo","password"}).items():setattr(item,k,v)
    db.add(item)
    try:db.commit()
    except IntegrityError:
        db.rollback();raise HTTPException(409,"Datos en conflicto: DNI, usuario o correo ya registrados.")
    db.refresh(item);return result(item,db)

@router.post("/",response_model=RepartidorRead,status_code=201)
def create_repartidor(payload:RepartidorCreate,db:Session=Depends(get_db)):return save(payload,db)

@router.put("/{repartidor_id}",response_model=RepartidorRead)
def update_repartidor(repartidor_id:uuid.UUID,payload:RepartidorCreate,db:Session=Depends(get_db)):
    item=db.get(Repartidor,repartidor_id)
    if not item:raise HTTPException(404,"Repartidor no encontrado.")
    return save(payload,db,item)
