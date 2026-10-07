from fastapi import APIRouter, Depends

from app.api.deps import require_roles
from app.api.routes import auth, drivers, health, orders, routes, vehicles

api_router = APIRouter()

api_router.include_router(health.router, tags=["health"])

# [RUTAS PÚBLICAS] - Abiertas para generar el Token JWT
api_router.include_router(auth.router, prefix="/auth", tags=["auth"])

# [RUTAS PROTEGIDAS] - Requieren Token JWT válido (Regla 2: Seguridad Extrema)
api_router.include_router(
    vehicles.router, 
    prefix="/vehicles", 
    tags=["vehiculos"], 
    dependencies=[Depends(require_roles("ADMIN"))]
)
from fastapi import Request, HTTPException
def driver_access(request: Request, user=Depends(require_roles("ADMIN", "REPARTIDOR"))):
    if user.rol != "ADMIN" and request.url.path.rstrip("/") != "/api/v1/drivers/me":
        raise HTTPException(403, "Acceso exclusivo de administrador.")

api_router.include_router(
    drivers.router, 
    prefix="/drivers", 
    tags=["repartidores"],
    dependencies=[Depends(driver_access)]
)
api_router.include_router(
    orders.router, 
    prefix="/orders", 
    tags=["pedidos"], 
    dependencies=[Depends(require_roles("ADMIN"))]
)
api_router.include_router(
    routes.router, 
    prefix="/routes", 
    tags=["rutas"], 
    dependencies=[Depends(require_roles("ADMIN", "REPARTIDOR"))]
)
