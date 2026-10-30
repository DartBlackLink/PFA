"""Real PostgreSQL/API acceptance cases; only the road provider is controlled."""

from concurrent.futures import ThreadPoolExecutor
from datetime import datetime, timedelta, timezone
from unittest.mock import patch
import uuid

from fastapi import HTTPException
from fastapi.testclient import TestClient
import pytest
from sqlalchemy import event, func, select

from app.api.routes import optimization
from app.core.security import get_password_hash
from app.db.session import SessionLocal
from app.main import app
from app.models.entities import (
    Pedido,
    PlanOptimizacion,
    Repartidor,
    Ruta,
    RutaDetalle,
    Usuario,
    Vehiculo,
)


def roads(points, deadline):
    return {"type": "LineString", "coordinates": [[lon, lat] for lat, lon in points]}, [
        (1, 2)
    ] * (len(points) - 1)


def matrix(points, deadline):
    size = len(points)
    return (
        [[0 if i == j else 1 for j in range(size)] for i in range(size)],
        [[0 if i == j else 2 for j in range(size)] for i in range(size)],
        {"provider_calls": 1, "cache_hit": False, "age_seconds": 0},
    )


@pytest.fixture
def api_case():
    suffix = uuid.uuid4().hex[:8]
    password = uuid.uuid4().hex
    email = f"opt.{suffix}@example.test"
    with SessionLocal() as db:
        db.add(
            Usuario(
                email=email,
                password_hash=get_password_hash(password),
                rol="ADMIN",
                estado="ACTIVO",
            )
        )
        db.commit()
    with TestClient(app) as client:
        response = client.post(
            "/api/v1/auth/login", data={"username": email, "password": password}
        )
        assert response.status_code == 200, response.text
        client.headers["Authorization"] = "Bearer " + response.json()["access_token"]
        vehicle = client.post(
            "/api/v1/vehicles/",
            json={
                "placa": "ga-" + suffix,
                "tipo": "Furgón",
                "capacidad_kg": 10,
                "consumo_km_l": 10,
                "factor_emision_kg_km": 0.2,
                "anio_fabricacion": 2025,
            },
        ).json()
        driver_response = client.post(
            "/api/v1/drivers/",
            json={
                "nombre": "QA Genético",
                "dni": f"{uuid.uuid4().int % 100000000:08d}",
                "licencia": "QA-GA-123",
                "categoria_licencia": "A-IIb",
                "anios_experiencia": 3,
                "contacto": "987654321",
                "disponible_desde": "08:00",
                "disponible_hasta": "17:00",
                "origen_latitud": -12.03,
                "origen_longitud": -77.01,
                "correo": f"ga.driver.{suffix}@example.test",
                "password": password,
            },
        )
        assert driver_response.status_code == 201, driver_response.text
        driver = driver_response.json()
        order_body = {
            "cliente_nombre": "QA Planificación",
            "direccion": "Av. QA Lima 123",
            "latitud": -12.04,
            "longitud": -77.02,
            "peso_kg": 5,
            "tipo_producto": "GENERAL",
            "ventana_inicio": "2030-01-02T09:00:00-05:00",
            "ventana_fin": "2030-01-02T16:30:00-05:00",
        }
        orders = []
        for _ in range(2):
            response = client.post("/api/v1/orders/", json=order_body)
            assert response.status_code == 201, response.text
            orders.append(response.json())
        payload = {
            "pedidos": [o["pedido_id"] for o in orders],
            "equipos": [
                {
                    "repartidor_id": driver["repartidor_id"],
                    "vehiculo_id": vehicle["vehiculo_id"],
                }
            ],
            "inicio_planificado": "2030-01-02T09:00:00-05:00",
            "poblacion": 8,
            "generaciones": 5,
        }
        with (
            patch.object(optimization, "road_matrix", side_effect=matrix),
            patch.object(optimization, "road_shape", side_effect=roads),
        ):
            yield client, payload, driver, vehicle, password


def preview(client, payload):
    response = client.post("/api/v1/optimizations/preview", json=payload)
    assert response.status_code == 201, response.text
    return response.json()


def route_count(plan_id):
    with SessionLocal() as db:
        return db.scalar(
            select(func.count())
            .select_from(Ruta)
            .where(Ruta.plan_optimizacion_id == uuid.UUID(plan_id))
        )


def test_gold_preview_confirm_consult_and_owner_routes(api_case):
    client, payload, driver, vehicle, password = api_case
    plan = preview(client, payload)
    assert plan["estado"] == "PREVISUALIZADO" and plan["ruta_ids"] == []
    assert all(
        stop["direccion"] == "Av. QA Lima 123"
        for route in plan["rutas"]
        for stop in route["entregas"]
    )
    with SessionLocal() as db:
        assert all(
            db.get(Pedido, uuid.UUID(key)).estado == "PENDIENTE"
            for key in payload["pedidos"]
        )
    result = client.post(f"/api/v1/optimizations/{plan['plan_id']}/confirm")
    assert result.status_code == 200, result.text
    confirmed = result.json()
    assert confirmed["estado"] == "CONFIRMADO" and len(confirmed["ruta_ids"]) == 1
    assert client.get(f"/api/v1/optimizations/{plan['plan_id']}").json() == confirmed
    with SessionLocal() as db:
        route = db.get(Ruta, uuid.UUID(confirmed["ruta_ids"][0]))
        assert route.algoritmo == "GA_VRPTW_1"
        assert float(route.combustible_l) > 0 and float(route.co2_kg) > 0
        stops = list(
            db.scalars(select(RutaDetalle).where(RutaDetalle.ruta_id == route.ruta_id))
        )
        assert len(stops) == 2 and all(stop.eta for stop in stops)
        for stop in stops:
            order = db.get(Pedido, stop.pedido_id)
            assert order.estado == "ASIGNADO"
            assert order.ventana_inicio <= stop.eta
            assert stop.eta + timedelta(minutes=5) <= order.ventana_fin
    with TestClient(app) as courier:
        login = courier.post(
            "/api/v1/auth/login",
            data={"username": driver["correo"], "password": password},
        )
        assert login.status_code == 200
        courier.headers["Authorization"] = "Bearer " + login.json()["access_token"]
        assert (
            courier.get("/api/v1/routes/" + confirmed["ruta_ids"][0]).status_code == 200
        )
        assert courier.get("/api/v1/optimizations/").status_code == 403
        assert (
            courier.post(f"/api/v1/optimizations/{plan['plan_id']}/confirm").status_code
            == 403
        )


def test_confirmation_is_idempotent_under_concurrency(api_case):
    client, payload, *_ = api_case
    plan = preview(client, payload)
    auth = client.headers["Authorization"]

    def confirm(_):
        with TestClient(app) as worker:
            response = worker.post(
                f"/api/v1/optimizations/{plan['plan_id']}/confirm",
                headers={"Authorization": auth},
            )
            assert response.status_code == 200, response.text
            return response.json()["ruta_ids"]

    with ThreadPoolExecutor(max_workers=2) as pool:
        first, second = list(pool.map(confirm, range(2)))
    assert first == second and route_count(plan["plan_id"]) == 1


@pytest.mark.parametrize("changed", ["order", "capacity", "shift"])
def test_stale_preview_cannot_change_orders_or_create_partial_routes(api_case, changed):
    client, payload, driver, vehicle, _ = api_case
    plan = preview(client, payload)
    with SessionLocal() as db:
        if changed == "order":
            db.get(Pedido, uuid.UUID(payload["pedidos"][0])).peso_kg = 4
        if changed == "capacity":
            db.get(Vehiculo, uuid.UUID(vehicle["vehiculo_id"])).capacidad_kg = 20
        if changed == "shift":
            from datetime import time

            db.get(
                Repartidor, uuid.UUID(driver["repartidor_id"])
            ).disponible_hasta = time(16)
        db.commit()
    response = client.post(f"/api/v1/optimizations/{plan['plan_id']}/confirm")
    assert response.status_code == 409, response.text
    assert route_count(plan["plan_id"]) == 0
    with SessionLocal() as db:
        assert all(
            db.get(Pedido, uuid.UUID(key)).estado == "PENDIENTE"
            for key in payload["pedidos"]
        )


def test_expired_plan_rejected_and_preview_consultable(api_case):
    client, payload, *_ = api_case
    plan = preview(client, payload)
    with SessionLocal() as db:
        db.get(PlanOptimizacion, uuid.UUID(plan["plan_id"])).vence_en = datetime.now(
            timezone.utc
        ) - timedelta(seconds=1)
        db.commit()
    assert (
        client.post(f"/api/v1/optimizations/{plan['plan_id']}/confirm").status_code
        == 409
    )
    assert client.get("/api/v1/optimizations/").status_code == 200
    assert client.get("/api/v1/optimizations/" + str(uuid.uuid4())).status_code == 404
    assert (
        client.post(
            "/api/v1/optimizations/" + str(uuid.uuid4()) + "/confirm"
        ).status_code
        == 404
    )


def test_unhappy_capacity_window_provider_and_invalid_resources(api_case):
    client, payload, driver, vehicle, _ = api_case
    with SessionLocal() as db:
        db.get(Vehiculo, uuid.UUID(vehicle["vehiculo_id"])).capacidad_kg = 1
        db.commit()
    assert client.post("/api/v1/optimizations/preview", json=payload).status_code == 422
    with SessionLocal() as db:
        db.get(Vehiculo, uuid.UUID(vehicle["vehiculo_id"])).capacidad_kg = 10
        for key in payload["pedidos"]:
            item = db.get(Pedido, uuid.UUID(key))
            item.ventana_fin = item.ventana_inicio + timedelta(minutes=1)
        db.commit()
    response = client.post("/api/v1/optimizations/preview", json=payload)
    assert response.status_code == 422
    with patch.object(
        optimization,
        "road_matrix",
        side_effect=HTTPException(503, "Proveedor no disponible"),
    ):
        assert (
            client.post("/api/v1/optimizations/preview", json=payload).status_code
            == 503
        )
    with SessionLocal() as db:
        db.get(Pedido, uuid.UUID(payload["pedidos"][0])).latitud = None
        db.commit()
    assert client.post("/api/v1/optimizations/preview", json=payload).status_code == 422
    assert (
        client.post(
            "/api/v1/optimizations/preview", json={**payload, "equipos": []}
        ).status_code
        == 422
    )
    assert (
        client.post(
            "/api/v1/optimizations/preview", json={**payload, "pedidos": []}
        ).status_code
        == 422
    )
    assert (
        client.post(
            "/api/v1/optimizations/preview",
            json={**payload, "pedidos": payload["pedidos"] * 2},
        ).status_code
        == 422
    )


def test_busy_server_returns_retry_after_without_writing(api_case):
    client, payload, *_ = api_case
    optimization._slot.acquire()
    try:
        response = client.post("/api/v1/optimizations/preview", json=payload)
        assert response.status_code == 429 and response.headers["Retry-After"] == "1"
    finally:
        optimization._slot.release()


def test_routes_are_batched_and_order_filter_is_validated(api_case):
    from app.api.routes.routes import results
    from app.db.session import engine

    client, payload, driver, vehicle, _ = api_case
    plan = preview(client, payload)
    confirmed = client.post(f"/api/v1/optimizations/{plan['plan_id']}/confirm").json()
    route_id = confirmed["ruta_ids"][0]
    route = client.get("/api/v1/routes/" + route_id).json()
    assert route["plan_optimizacion_id"] == plan["plan_id"]
    assert all(stop["eta"] for stop in route["entregas"])
    assigned = client.get("/api/v1/orders/?estado=ASIGNADO&limit=1000").json()
    pending = client.get("/api/v1/orders/?estado=PENDIENTE&limit=1000").json()
    assert set(payload["pedidos"]).issubset({row["pedido_id"] for row in assigned})
    assert not set(payload["pedidos"]).intersection(row["pedido_id"] for row in pending)
    assert client.get("/api/v1/orders/?estado=INVALID").status_code == 422
    with SessionLocal() as db:
        for _ in range(3):
            db.add(
                Ruta(
                    vehiculo_id=uuid.UUID(vehicle["vehiculo_id"]),
                    repartidor_id=uuid.UUID(driver["repartidor_id"]),
                    algoritmo="QA_BATCH",
                    estado="PLANIFICADA",
                )
            )
        db.commit()
    counts = []
    for size in (1, 4):
        calls = []

        def count(connection, cursor, statement, parameters, context, many):
            if statement.lstrip().upper().startswith("SELECT"):
                calls.append(statement)

        event.listen(engine, "before_cursor_execute", count)
        try:
            with SessionLocal() as db:
                routes = db.scalars(
                    select(Ruta)
                    .where(Ruta.repartidor_id == uuid.UUID(driver["repartidor_id"]))
                    .limit(size)
                )
                data = results(routes, db)
                assert len(data) == size
        finally:
            event.remove(engine, "before_cursor_execute", count)
        counts.append(len(calls))
    assert counts == [4, 4]
