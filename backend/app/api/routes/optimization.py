"""ADMIN-only genetic preview; explicit, idempotent and atomic confirmation."""

from concurrent.futures import ThreadPoolExecutor
from dataclasses import asdict
from datetime import datetime, timedelta, timezone
from threading import BoundedSemaphore
from time import monotonic
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.api.deps import require_roles
from app.db.session import get_db
from app.models.entities import PlanOptimizacion, Ruta, RutaDetalle, Usuario
from app.optimization_schemas import OptimizationRequest, PlanView
from app.services.genetic import NoFeasiblePlan, Parameters, evaluate_route, solve
from app.services.matrix import road_matrix, road_shape
from app.services.optimization_context import load_context
from app.services.scheduling import schedule

router = APIRouter(dependencies=[Depends(require_roles("ADMIN"))])
_slot = BoundedSemaphore(1)


def view(plan, db):
    warnings = (
        plan.solucion["advertencias"][1:]
        if plan.estado == "CONFIRMADO"
        else plan.solucion["advertencias"]
    )
    return {
        "plan_id": plan.plan_id,
        "estado": plan.estado,
        "creado_en": plan.creado_en,
        "vence_en": plan.vence_en,
        "algoritmo": "GA_VRPTW_1",
        "estadisticas": plan.solucion["estadisticas"],
        "rutas": plan.solucion["rutas"],
        "advertencias": warnings,
        "ruta_ids": list(
            db.scalars(
                select(Ruta.ruta_id)
                .where(Ruta.plan_optimizacion_id == plan.plan_id)
                .order_by(Ruta.ruta_id)
            )
        ),
    }


def _validated_roads(plan, context, distance, duration, deadline):
    deliveries = {d.identifier: d for d in context["deliveries"]}
    teams = {team.identifier: team for team in context["teams"]}
    paths = []
    for route in plan.routes:
        team = teams[route.team]
        indices = [team.origin] + [deliveries[key].node for key in route.deliveries]
        if context["rules"].return_to_origin:
            indices.append(team.origin)
        paths.append(indices)
    with ThreadPoolExecutor(max_workers=4) as pool:
        shapes = list(
            pool.map(
                lambda indices: road_shape(
                    [context["coordinates"][i] for i in indices], deadline
                ),
                paths,
            )
        )
    final_distance = [row[:] for row in distance]
    final_duration = [row[:] for row in duration]
    for indices, (_, legs) in zip(paths, shapes):
        for (source, destination), (km, minutes) in zip(
            zip(indices, indices[1:]), legs
        ):
            final_distance[source][destination] = km
            final_duration[source][destination] = minutes
    routes = []
    for candidate, (geometry, _) in zip(plan.routes, shapes):
        team = teams[candidate.team]
        checked = evaluate_route(
            team,
            [deliveries[key] for key in candidate.deliveries],
            final_distance,
            final_duration,
            context["rules"],
        )
        if checked is None:
            raise HTTPException(
                422,
                "El recorrido vial final incumple una restricción; ajusta horario o equipos y recalcula.",
            )
        selection = context["payload"].equipos[int(team.identifier)]
        driver, _ = context["drivers"][selection.repartidor_id]
        vehicle = context["vehicles"][selection.vehiculo_id]
        start = context["start"]
        routes.append(
            {
                **asdict(checked),
                "repartidor_id": str(selection.repartidor_id),
                "vehiculo_id": str(selection.vehiculo_id),
                "repartidor_nombre": driver.nombre,
                "vehiculo_placa": vehicle.placa,
                "geometria": geometry,
                "origen_latitud": context["coordinates"][team.origin][0],
                "origen_longitud": context["coordinates"][team.origin][1],
                "inicio_planificado": (
                    start + timedelta(minutes=checked.start)
                ).isoformat(),
                "fin_planificado": (start + timedelta(minutes=checked.end)).isoformat(),
                "total_min": checked.end - checked.start,
                "entregas": [
                    {
                        "pedido_id": stop.delivery,
                        "direccion": context["orders"][UUID(stop.delivery)].direccion,
                        "punto_referencia": context["orders"][
                            UUID(stop.delivery)
                        ].punto_referencia,
                        "peso_kg": float(
                            context["orders"][UUID(stop.delivery)].peso_kg
                        ),
                        "eta": (
                            start + timedelta(minutes=stop.service_start)
                        ).isoformat(),
                        "fin_servicio": (
                            start + timedelta(minutes=stop.finish)
                        ).isoformat(),
                    }
                    for stop in checked.stops
                ],
            }
        )
    return routes


@router.post("/preview", response_model=PlanView, status_code=201)
def preview(
    payload: OptimizationRequest,
    db: Session = Depends(get_db),
    user: Usuario = Depends(require_roles("ADMIN")),
):
    if not _slot.acquire(blocking=False):
        raise HTTPException(
            429,
            "Hay una optimización en curso; espera y vuelve a intentar.",
            headers={"Retry-After": "1"},
        )
    try:
        owner = user.usuario_id
        context = load_context(payload, db)
        if any(
            d.weight > max(team.capacity for team in context["teams"])
            for d in context["deliveries"]
        ):
            raise HTTPException(
                422,
                "Un pedido supera la capacidad de todos los equipos; ajusta la flota.",
            )
        context["payload"] = payload
        # Provider I/O runs after the read transaction; confirmation locks a fresh snapshot.
        for driver, account in context["drivers"].values():
            db.expunge(driver)
            db.expunge(account)
        for vehicle in context["vehicles"].values():
            db.expunge(vehicle)
        for order in context["orders"].values():
            db.expunge(order)
        db.rollback()
        deadline = monotonic() + 40
        distance, duration, provider = road_matrix(context["coordinates"], deadline)
        parameters = Parameters(
            seed=payload.semilla,
            population=payload.poblacion,
            generations=payload.generaciones,
            seconds=min(payload.limite_calculo_seg, max(0.01, deadline - monotonic())),
        )
        try:
            plan, statistics = solve(
                context["deliveries"],
                context["teams"],
                distance,
                duration,
                context["rules"],
                parameters,
            )
        except NoFeasiblePlan as error:
            raise HTTPException(
                422,
                {"mensaje": str(error), "pedidos_sin_asignar": list(error.unassigned)},
            ) from error
        except ValueError as error:
            raise HTTPException(
                422, "Los datos no permiten una planificación válida."
            ) from error
        routes = _validated_roads(plan, context, distance, duration, deadline)
        statistics.update(provider)
        statistics["parametros_motor"] = asdict(parameters)
        statistics.update(
            {
                "pedidos": len(payload.pedidos),
                "rutas": len(routes),
                "distancia_km": sum(r["distance"] for r in routes),
                "combustible_l": sum(r["fuel"] for r in routes),
                "co2_kg": sum(r["carbon"] for r in routes),
                "fuente": "OSRM; tiempos estimados sin tráfico en tiempo real",
                "restricciones": "Capacidad, ventana completa, turno, jornada, descanso y solapamientos",
                "retorno_al_origen": payload.regresar_al_origen,
            }
        )
        stored = PlanOptimizacion(
            usuario_id=owner,
            vence_en=datetime.now(timezone.utc) + timedelta(minutes=10),
            solicitud=payload.model_dump(mode="json"),
            huella_datos=context["fingerprint"],
            solucion={
                "rutas": routes,
                "estadisticas": statistics,
                "advertencias": [
                    "Vista previa: los pedidos siguen pendientes hasta confirmar.",
                    "La búsqueda no garantiza el óptimo global.",
                    "Jornada y descanso son parámetros operativos; no certifican cumplimiento legal.",
                ],
            },
        )
        db.add(stored)
        db.commit()
        db.refresh(stored)
        return view(stored, db)
    finally:
        _slot.release()


@router.get("/")
def list_plans(limit: int = Query(20, ge=1, le=50), db: Session = Depends(get_db)):
    return [
        {
            "plan_id": str(plan.plan_id),
            "estado": plan.estado,
            "creado_en": plan.creado_en,
            "estadisticas": plan.solucion["estadisticas"],
        }
        for plan in db.scalars(
            select(PlanOptimizacion)
            .order_by(PlanOptimizacion.creado_en.desc())
            .limit(limit)
        )
    ]


@router.get("/{plan_id}", response_model=PlanView)
def get_plan(plan_id: UUID, db: Session = Depends(get_db)):
    plan = db.get(PlanOptimizacion, plan_id)
    if plan is None:
        raise HTTPException(404, "Plan no encontrado.")
    return view(plan, db)


@router.post("/{plan_id}/confirm", response_model=PlanView)
def confirm(plan_id: UUID, db: Session = Depends(get_db)):
    plan = db.scalar(
        select(PlanOptimizacion)
        .where(PlanOptimizacion.plan_id == plan_id)
        .with_for_update()
    )
    if plan is None:
        raise HTTPException(404, "Plan no encontrado.")
    if plan.estado == "CONFIRMADO":
        return view(plan, db)
    if plan.vence_en < datetime.now(timezone.utc):
        raise HTTPException(409, "La vista previa venció. Genera una nueva propuesta.")
    payload = OptimizationRequest.model_validate(plan.solicitud)
    context = load_context(payload, db, lock=True)
    if context["fingerprint"] != plan.huella_datos:
        raise HTTPException(
            409, "Los pedidos o recursos cambiaron. Vuelve a generar la propuesta."
        )
    for route in plan.solucion["rutas"]:
        driver, _ = context["drivers"][UUID(route["repartidor_id"])]
        vehicle = context["vehicles"][UUID(route["vehiculo_id"])]
        start = datetime.fromisoformat(route["inicio_planificado"])
        duration = (
            route["total_min"]
            - len(route["entregas"]) * payload.servicio_min_por_entrega
        )
        _, end = schedule(
            db,
            driver,
            vehicle,
            start,
            duration,
            len(route["entregas"]),
            payload.servicio_min_por_entrega,
        )
        stored = Ruta(
            plan_optimizacion_id=plan.plan_id,
            vehiculo_id=vehicle.vehiculo_id,
            repartidor_id=driver.repartidor_id,
            algoritmo="GA_VRPTW_1",
            estado="PLANIFICADA",
            inicio_planificado=start,
            fin_planificado=end,
            servicio_min_por_entrega=payload.servicio_min_por_entrega,
            origen_latitud=route["origen_latitud"],
            origen_longitud=route["origen_longitud"],
            geometria=route["geometria"],
            distancia_km=route["distance"],
            tiempo_min=route["travel"],
            combustible_l=route["fuel"],
            co2_kg=route["carbon"],
        )
        db.add(stored)
        db.flush()
        for sequence, delivery in enumerate(route["entregas"], 1):
            identifier = UUID(delivery["pedido_id"])
            db.add(
                RutaDetalle(
                    ruta_id=stored.ruta_id,
                    pedido_id=identifier,
                    secuencia=sequence,
                    eta=datetime.fromisoformat(delivery["eta"]),
                )
            )
            context["orders"][identifier].estado = "ASIGNADO"
    plan.estado = "CONFIRMADO"
    db.commit()
    db.refresh(plan)
    return view(plan, db)
