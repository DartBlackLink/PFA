from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import select

from app.api.router import api_router
from app.core.config import get_settings
from app.core.security import get_password_hash
from app.db.session import SessionLocal
from app.models.entities import Usuario

settings = get_settings()

from contextlib import asynccontextmanager

@asynccontextmanager
async def lifespan(app):
    with SessionLocal() as db:
        admin = db.scalar(select(Usuario).where(Usuario.email == settings.admin_email))
        if admin is None:
            db.add(
                Usuario(
                    email=settings.admin_email,
                    password_hash=get_password_hash(settings.admin_password),
                    rol="ADMIN",
                    estado="ACTIVO",
                )
            )
            db.commit()
        driver = db.scalar(select(Usuario).where(Usuario.email == settings.driver_email))
        if driver is None:
            db.add(
                Usuario(
                    email=settings.driver_email,
                    password_hash=get_password_hash(settings.driver_password),
                    rol="REPARTIDOR",
                    estado="ACTIVO",
                )
            )
            db.commit()
    yield

app = FastAPI(title=settings.app_name, lifespan=lifespan)

# [DEVSECOPS] Configuración de CORS (Cross-Origin Resource Sharing)
# Permite que Flutter Web (que corre en un puerto dinámico) se comunique con FastAPI.
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origin_list,  # En producción estricta aquí irían solo los dominios oficiales. Para dev usamos "*"
    allow_credentials=False,
    allow_methods=["*"],  # Permite GET, POST, PUT, DELETE, etc.
    allow_headers=["Authorization", "Content-Type"],
    expose_headers=["Retry-After"],  # Permite inyectar el token JWT en la cabecera Authorization
)

# Enrutador principal
app.include_router(api_router, prefix="/api/v1")
