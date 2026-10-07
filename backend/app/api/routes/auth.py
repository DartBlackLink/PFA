import hashlib, hmac, math
from datetime import datetime, timedelta, timezone
from fastapi import APIRouter, Depends, HTTPException
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy import select, func
from sqlalchemy.dialects.postgresql import insert
from sqlalchemy.orm import Session
from app.core.config import get_settings
from app.core.security import create_access_token, verify_password, get_password_hash
from app.db.session import get_db
from app.models.entities import Usuario, ControlAcceso
from app.schemas import Token
from app.api.deps import get_current_user

router=APIRouter()
DUMMY_HASH=get_password_hash("invalid-account-comparison")

def utcnow(): return datetime.now(timezone.utc)

def denied(seconds):
    return HTTPException(429, detail="Acceso temporalmente bloqueado. Espera antes de volver a intentar.", headers={"Retry-After":str(seconds)})

@router.post("/login",response_model=Token)
def login_access_token(form_data:OAuth2PasswordRequestForm=Depends(), db:Session=Depends(get_db)):
    email=form_data.username.strip().lower()
    key=hmac.new(get_settings().secret_key.encode(),email.encode(),hashlib.sha256).hexdigest()
    db.execute(insert(ControlAcceso).values(identificador_hmac=key,intentos_fallidos=0,actualizado_en=utcnow()).on_conflict_do_nothing())
    control=db.scalar(select(ControlAcceso).where(ControlAcceso.identificador_hmac==key).with_for_update())
    now=utcnow()
    if control.bloqueo_hasta and control.bloqueo_hasta>now:
        seconds=max(1,math.ceil((control.bloqueo_hasta-now).total_seconds()))
        db.rollback()
        raise denied(seconds)
    user=db.scalar(select(Usuario).where(func.lower(Usuario.email)==email))
    try:
        valid=verify_password(form_data.password,user.password_hash if user else DUMMY_HASH)
    except (ValueError,TypeError): valid=False
    if not valid or user is None or user.estado!="ACTIVO" or user.rol not in ("ADMIN","REPARTIDOR"):
        control.intentos_fallidos=min(5,control.intentos_fallidos+1)
        seconds={3:5,4:10,5:300}.get(control.intentos_fallidos,0)
        control.bloqueo_hasta=now+timedelta(seconds=seconds) if seconds else None
        control.actualizado_en=now
        db.commit()
        if seconds: raise denied(seconds)
        raise HTTPException(401,detail="Correo o contraseña incorrectos.")
    control.intentos_fallidos=0;control.bloqueo_hasta=None;control.actualizado_en=now
    db.commit()
    return Token(access_token=create_access_token(user.email,user.rol),token_type="bearer",rol=user.rol)

@router.get("/me")
def current_identity(user:Usuario=Depends(get_current_user)):
    return {"usuario_id":str(user.usuario_id),"email":user.email,"rol":user.rol,"estado":user.estado}
