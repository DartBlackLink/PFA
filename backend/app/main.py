from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.exceptions import RequestValidationError
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.trustedhost import TrustedHostMiddleware
from fastapi.responses import JSONResponse
from sqlalchemy import select

from app.api.router import api_router
from app.core.config import get_settings
from app.core.request_limits import RequestSizeLimitMiddleware
from app.core.security import get_password_hash
from app.db.session import SessionLocal
from app.models.entities import Usuario

settings = get_settings()


@asynccontextmanager
async def lifespan(app):
    # Existing users are preserved; demo accounts are never enabled implicitly.
    if settings.bootstrap_demo_users:
        with SessionLocal() as db:
            for email, password, role in (
                (settings.admin_email, settings.admin_password, "ADMIN"),
                (settings.driver_email, settings.driver_password, "REPARTIDOR"),
            ):
                if db.scalar(select(Usuario).where(Usuario.email == email)) is None:
                    db.add(
                        Usuario(
                            email=email,
                            password_hash=get_password_hash(password),
                            rol=role,
                            estado="ACTIVO",
                        )
                    )
            db.commit()
    yield


app = FastAPI(title=settings.app_name, lifespan=lifespan)
app.add_middleware(TrustedHostMiddleware, allowed_hosts=settings.trusted_host_list)
app.add_middleware(RequestSizeLimitMiddleware)


@app.middleware("http")
async def secure_headers(request, call_next):
    response = await call_next(request)
    response.headers["X-Content-Type-Options"] = "nosniff"
    response.headers["X-Frame-Options"] = "DENY"
    response.headers["Referrer-Policy"] = "no-referrer"
    response.headers["Cache-Control"] = "no-store"
    return response


app.include_router(api_router, prefix="/api/v1")


@app.exception_handler(RequestValidationError)
async def safe_validation_error(request, error):
    details = [
        {"loc": issue["loc"], "msg": issue["msg"], "type": issue["type"]}
        for issue in error.errors()
    ]
    return JSONResponse(status_code=422, content={"detail": details})


@app.exception_handler(Exception)
async def safe_server_error(request, error):
    return JSONResponse(
        status_code=500,
        content={"detail": "No se pudo completar la operación. Reintenta."},
        headers={"Cache-Control": "no-store", "X-Content-Type-Options": "nosniff"},
    )


# Added last so CORS also covers responses returned by inner middleware.
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origin_list,
    allow_credentials=False,
    allow_methods=["GET", "POST", "PUT", "OPTIONS"],
    allow_headers=["Authorization", "Content-Type"],
    expose_headers=["Retry-After"],
)
