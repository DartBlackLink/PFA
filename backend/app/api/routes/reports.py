"""ADMIN-only reporting; reads stored results, no third-party requests."""

import uuid
from datetime import datetime, timezone
from decimal import Decimal

from fastapi import APIRouter, Depends, HTTPException, Query, Response
from pydantic import Field, model_validator
from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.api.deps import require_roles
from app.db.session import get_db
from app.models.entities import ConfiguracionAmbiental, Pedido, Ruta, RutaDetalle, Usuario
from app.schemas import ValidatedInput
from app.services.report_pdf import route_pdf
from app.services.sustainability import aggregate_metric, route_indicators, window_summary

router = APIRouter(dependencies=[Depends(require_roles("ADMIN"))])


class EnvironmentalInput(ValidatedInput):
    factor_kg_por_unidad: Decimal | None = Field(default=None, gt=0, le=100000000, max_digits=16, decimal_places=6)
    unidad: str | None = Field(default=None, min_length=2, max_length=80)
    fuente: str | None = Field(default=None, min_length=10, max_length=500)

    @model_validator(mode="after")
    def complete(self):
        if any(v is not None for v in (self.factor_kg_por_unidad, self.unidad, self.fuente)) and not all(
            v is not None for v in (self.factor_kg_por_unidad, self.unidad, self.fuente)
        ):
            raise ValueError("Indica factor, unidad y fuente juntos, o elimina los tres.")
        return self


def config_data(config):
    return {"factor_kg_por_unidad": float(config.factor_kg_por_unidad) if config and config.factor_kg_por_unidad else None,
            "unidad": config.unidad if config else None, "fuente": config.fuente if config else None,
            "actualizado_en": config.actualizado_en if config else None}


@router.get("/environment")
def environmental_config(db: Session = Depends(get_db)):
    return config_data(db.get(ConfiguracionAmbiental, 1))


@router.put("/environment")
def update_environment(payload: EnvironmentalInput, db: Session = Depends(get_db), user: Usuario = Depends(require_roles("ADMIN"))):
    # Serialize both first insertion and later updates using a transaction advisory lock.
    db.execute(select(func.pg_advisory_xact_lock(20261114)))
    config = db.get(ConfiguracionAmbiental, 1)
    if config is None:
        config = ConfiguracionAmbiental(configuracion_id=1)
        db.add(config)
    for key, value in payload.model_dump().items():
        setattr(config, key, value)
    config.actualizado_por = user.usuario_id
    config.actualizado_en = datetime.now(timezone.utc)
    db.commit()
    return config_data(config)


@router.get("/summary")
def summary(db: Session = Depends(get_db)):
    routes = db.execute(select(Ruta.distancia_km, Ruta.combustible_l, Ruta.co2_kg).where(Ruta.estado != "CANCELADA")).all()
    deliveries = db.execute(select(RutaDetalle, Pedido, Ruta.servicio_min_por_entrega).join(Pedido, Pedido.pedido_id == RutaDetalle.pedido_id)
                            .join(Ruta, Ruta.ruta_id == RutaDetalle.ruta_id).where(Ruta.estado != "CANCELADA")).all()
    return {"rutas": len(routes), "excluye_canceladas": True,
            "distancia_km": aggregate_metric(r[0] for r in routes),
            "combustible_l": aggregate_metric(r[1] for r in routes),
            "co2_kg": aggregate_metric(r[2] for r in routes), "ventanas": window_summary(deliveries),
            "naturaleza": "Suma de estimaciones de la última versión de cada ruta vigente/finalizada; después de reoptimizar son del tramo pendiente. No es el acumulado físico de entregas ni ahorro acreditado."}


@router.get("/routes")
def list_report_routes(skip: int = Query(0, ge=0), limit: int = Query(25, ge=1, le=100), db: Session = Depends(get_db)):
    query = select(Ruta).where(Ruta.estado != "CANCELADA")
    total = db.scalar(select(func.count()).select_from(query.subquery()))
    rows = db.scalars(query.order_by(Ruta.creado_en.desc(), Ruta.ruta_id).offset(skip).limit(limit))
    return {"total": total, "items": [{"ruta_id": str(r.ruta_id), "version": r.version, "estado": r.estado,
                                      "creado_en": r.creado_en, "algoritmo": r.algoritmo} for r in rows]}


def report(db, ruta_id):
    route = db.get(Ruta, ruta_id)
    if route is None:
        raise HTTPException(404, "Ruta no encontrada.")
    if route.estado == "CANCELADA":
        raise HTTPException(409, "Selecciona una planificación vigente o finalizada, no una ruta cancelada.")
    if not db.scalar(select(RutaDetalle.ruta_detalle_id).where(RutaDetalle.ruta_id == ruta_id).limit(1)):
        raise HTTPException(409, "La ruta no tiene entregas planificadas.")
    return route_indicators(db, route, db.get(ConfiguracionAmbiental, 1))


@router.get("/routes/{ruta_id}")
def route_report(ruta_id: uuid.UUID, db: Session = Depends(get_db)):
    return report(db, ruta_id)


@router.get("/routes/{ruta_id}/pdf", responses={200: {"content": {"application/pdf": {}}, "description": "PDF de ruta e indicadores"}}, response_class=Response)
def download_pdf(ruta_id: uuid.UUID, db: Session = Depends(get_db)):
    data = report(db, ruta_id)
    return Response(route_pdf(data), media_type="application/pdf", headers={
        "Content-Disposition": f'attachment; filename="ecologistica-{ruta_id}-v{data["version"]}.pdf"',
        "Cache-Control": "no-store",
    })
