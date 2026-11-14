"""Stored route estimates and actual deliveries; never invent missing values."""

from decimal import Decimal
from datetime import timedelta

from app.models.entities import Pedido, RutaDetalle
from sqlalchemy import select


def number(value):
    return float(value) if value is not None else None


def window_summary(rows, service_minutes=None):
    planned = actual = planned_known = actual_known = delivered = 0
    for row in rows:
        detail, order = row[:2]
        service = row[2] if len(row) > 2 else service_minutes
        if detail.eta is not None and service is not None:
            planned_known += 1
            planned += int(order.ventana_inicio <= detail.eta and detail.eta + timedelta(minutes=service) <= order.ventana_fin)
        if detail.estado_entrega == "ENTREGADO":
            delivered += 1
            if detail.entregado_en is not None:
                actual_known += 1
                actual += int(order.ventana_inicio <= detail.entregado_en <= order.ventana_fin)
    return {
        "entregas": len(rows), "entregadas": delivered,
        "previstas_evaluadas": planned_known, "previstas_en_ventana": planned,
        "reales_evaluadas": actual_known, "reales_en_ventana": actual,
        "cumplimiento_previsto_pct": 100 * planned / planned_known if planned_known else None,
        "cumplimiento_real_pct": 100 * actual / actual_known if actual_known else None,
    }


def route_indicators(db, route, config=None):
    rows = db.execute(select(RutaDetalle, Pedido).join(
        Pedido, Pedido.pedido_id == RutaDetalle.pedido_id
    ).where(RutaDetalle.ruta_id == route.ruta_id)).all()
    equivalence = None
    if config is not None and config.factor_kg_por_unidad and route.co2_kg is not None:
        equivalence = {
            "valor": number(route.co2_kg / config.factor_kg_por_unidad),
            "unidad": config.unidad, "factor_kg_por_unidad": number(config.factor_kg_por_unidad),
            "fuente": config.fuente,
            "advertencia": "Equivalencia teórica; no acredita compensación, captura real ni créditos de carbono.",
        }
    return {
        "ruta_id": str(route.ruta_id), "version": route.version, "estado": route.estado,
        "algoritmo": route.algoritmo,
        "inicio_planificado": route.inicio_planificado,
        "distancia_km": number(route.distancia_km), "tiempo_min": number(route.tiempo_min),
        "combustible_l": number(route.combustible_l), "co2_kg": number(route.co2_kg),
        "ventanas": window_summary(rows, route.servicio_min_por_entrega), "equivalencia": equivalence,
        "ambito": "Huancayo y alrededores urbanos autorizados, Junín, Perú",
        "zona_horaria": "America/Lima",
        "metodologia": "Estimaciones de la última versión guardada. Después de reoptimizar, distancia, tiempo, combustible y CO₂ corresponden al tramo pendiente recalculado, no al acumulado físico de todo el recorrido. Las entregas realizadas conservan su historial. No son mediciones reales ni tráfico en vivo. Sin línea base comparable no se declara ahorro.",
    }


def aggregate_metric(values):
    """An incomplete set must not appear to be a complete total or zero."""
    values = list(values)
    known = [Decimal(v) for v in values if v is not None]
    return {"valor": float(sum(known)) if known and len(known) == len(values) else None,
            "rutas_con_dato": len(known), "rutas_sin_dato": len(values) - len(known)}
