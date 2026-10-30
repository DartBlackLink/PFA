"""Negative security and boundary cases, with no external network or real data."""

from datetime import datetime, timedelta, timezone
from decimal import Decimal
from types import SimpleNamespace
from unittest.mock import patch
import uuid

import httpx
import jwt
import pytest
from fastapi import HTTPException
from fastapi.testclient import TestClient
from pydantic import ValidationError

from app.api.deps import get_current_user, require_roles
from app.core.config import Settings, get_settings
from app.core.security import create_access_token, get_password_hash, verify_password
from app.main import app
from app.schemas import PedidoCreate, RepartidorCreate, RutaCreate, VehiculoCreate
from app.services import provider_http, routing, scheduling


def settings(**changes):
    return Settings(
        _env_file=None,
        database_url="postgresql://qa/test",
        secret_key="test-only-random-configuration-0123456789abcdef",
        **changes,
    )


@pytest.mark.parametrize(
    "changes",
    [
        {"secret_key": "short"},
        {"secret_key": "a" * 40},
        {"algorithm": "none"},
        {"access_token_expire_minutes": 0},
        {"cors_origins": "*"},
        {"trusted_hosts": "*"},
        {"routing_base_url": "file:///etc/passwd"},
        {"geocoding_base_url": "http://external.example"},
        {"geocoding_base_url": "https://127.0.0.1"},
        {"geocoding_base_url": "https://10.0.0.1"},
        {"routing_base_url": "https://user:pass@external.example"},
        {"bootstrap_demo_users": True},
    ],
)
def test_reject_insecure_settings(changes):
    base = dict(
        database_url="postgresql://qa/test",
        secret_key="test-only-random-configuration-0123456789abcdef",
    )
    with pytest.raises(ValidationError):
        Settings(_env_file=None, **(base | changes))


def test_local_providers_need_explicit_test_option():
    assert (
        settings(
            allow_local_provider_urls=True, routing_base_url="http://127.0.0.1:8090"
        ).algorithm
        == "HS256"
    )
    assert settings().trusted_host_list == [
        "localhost",
        "127.0.0.1",
        "backend",
        "testserver",
    ]


def test_bcrypt_and_legacy_hash_compatibility():
    hashed = get_password_hash("CredencialQA123!")
    assert verify_password("CredencialQA123!", hashed)
    assert not verify_password("incorrecta", hashed)
    assert not verify_password("x", "corrupt-hash")
    assert not verify_password("x" * 73, hashed)
    assert not verify_password("", hashed)
    with pytest.raises(ValueError):
        get_password_hash("short")
    with pytest.raises(ValueError):
        get_password_hash("á" * 37)


def test_jwt_expiry_required_claims_and_roles():
    cfg = get_settings()
    token = create_access_token("qa@example.test", "ADMIN")
    claims = jwt.decode(token, cfg.secret_key, algorithms=["HS256"])
    assert claims["sub"] == "qa@example.test"
    assert claims["exp"] > claims["iat"]
    assert claims["jti"]
    db = SimpleNamespace(scalar=lambda query: None)
    for payload in [
        {"sub": "qa@example.test"},
        {"exp": datetime.now(timezone.utc) + timedelta(minutes=1)},
        {"sub": "", "exp": datetime.now(timezone.utc) + timedelta(minutes=1)},
        {
            "sub": "qa@example.test",
            "exp": datetime.now(timezone.utc) - timedelta(seconds=1),
        },
    ]:
        with pytest.raises(HTTPException) as error:
            get_current_user(jwt.encode(payload, cfg.secret_key, algorithm="HS256"), db)
        assert error.value.status_code == 401
    with pytest.raises(HTTPException):
        get_current_user("invalid-token", db)
    with pytest.raises(HTTPException) as error:
        require_roles("ADMIN")(SimpleNamespace(rol="REPARTIDOR"))
    assert error.value.status_code == 403


def test_anonymous_rbac_headers_host_and_cors():
    with TestClient(app) as client:
        for path in [
            "/vehicles/",
            "/drivers/",
            "/orders/",
            "/routes/",
            "/locations/search?q=Huancayo",
        ]:
            assert client.get("/api/v1" + path).status_code == 401
        response = client.get("/api/v1/health")
        assert response.headers["x-content-type-options"] == "nosniff"
        assert response.headers["cache-control"] == "no-store"
        assert (
            client.get(
                "/api/v1/health", headers={"Host": "attacker.example"}
            ).status_code
            == 400
        )
        response = client.options(
            "/api/v1/auth/login",
            headers={
                "Origin": "https://attacker.example",
                "Access-Control-Request-Method": "POST",
            },
        )
        assert "access-control-allow-origin" not in response.headers
        response = client.options(
            "/api/v1/auth/login",
            headers={
                "Origin": "http://localhost:8080",
                "Access-Control-Request-Method": "POST",
            },
        )
        assert (
            response.headers["access-control-allow-origin"] == "http://localhost:8080"
        )
        assert (
            client.post(
                "/api/v1/auth/login", data={"username": "x" * 255, "password": "x"}
            ).status_code
            == 401
        )


def test_request_size_and_validation_do_not_echo_credentials():
    app.dependency_overrides[get_current_user] = lambda: SimpleNamespace(rol="ADMIN")
    try:
        with TestClient(app) as client:
            assert (
                client.post("/api/v1/orders/", content=b"x" * 65537).status_code == 413
            )
            assert (
                client.post(
                    "/api/v1/orders/", headers={"Content-Length": "-1"}
                ).status_code
                == 400
            )
            assert (
                client.post(
                    "/api/v1/orders/", headers={"Content-Length": "bad"}
                ).status_code
                == 400
            )
            response = client.post(
                "/api/v1/drivers/", json={"password": "sensitive-marker"}
            )
            assert response.status_code == 422
            assert "sensitive-marker" not in response.text
    finally:
        app.dependency_overrides.clear()


def test_server_failure_does_not_leak_exception():
    from app.db.session import get_db

    def unavailable_database():
        raise RuntimeError("private-database-error-marker")

    app.dependency_overrides[get_current_user] = lambda: SimpleNamespace(rol="ADMIN")
    app.dependency_overrides[get_db] = unavailable_database
    try:
        with TestClient(app, raise_server_exceptions=False) as client:
            response = client.get("/api/v1/vehicles/")
            assert response.status_code == 500
            assert response.json()["detail"]
            assert "private-database-error-marker" not in response.text
    finally:
        app.dependency_overrides.clear()


@pytest.mark.anyio
async def test_chunked_request_limit_and_disconnect():
    from app.core.request_limits import RequestSizeLimitMiddleware

    called, responses = [], []

    async def inner(scope, receive, send):
        called.append(await receive())

    async def send(message):
        responses.append(message)

    for messages, expected in [
        (
            [
                {"type": "http.request", "body": b"x" * 50, "more_body": True},
                {"type": "http.request", "body": b"x" * 50},
            ],
            413,
        ),
        ([{"type": "http.disconnect"}], None),
    ]:
        responses.clear()

        async def receive():
            return messages.pop(0)

        await RequestSizeLimitMiddleware(inner, max_bytes=64)(
            {"type": "http", "method": "POST", "headers": []}, receive, send
        )
        if expected:
            assert responses[0]["status"] == expected
        else:
            assert not responses
    assert not called


@pytest.fixture
def anyio_backend():
    return "asyncio"


@pytest.fixture
def vehicle_payload():
    return dict(
        placa="QA-123",
        tipo="Furgón",
        capacidad_kg=500,
        consumo_km_l=12,
        factor_emision_kg_km=0.1,
        anio_fabricacion=2025,
    )


@pytest.mark.parametrize(
    "changes",
    [
        {"capacidad_kg": "NaN"},
        {"consumo_km_l": "Infinity"},
        {"capacidad_kg": 100000000},
        {"factor_emision_kg_km": -1},
        {"tipo": "  "},
        {"placa": "';DROP TABLE usuario;--"},
        {"rol": "ADMIN"},
    ],
)
def test_vehicle_boundaries_rejected(vehicle_payload, changes):
    with pytest.raises(ValidationError):
        VehiculoCreate(**(vehicle_payload | changes))


def test_normalization_and_order_timezone():
    payload = dict(
        cliente_nombre=" QA ",
        direccion=" Calle QA 123 ",
        latitud=-12.07,
        longitud=-75.21,
        peso_kg="1.25",
        ventana_inicio="2026-10-23T09:00:00-05:00",
        ventana_fin="2026-10-23T10:00:00-05:00",
        tipo_producto=" Caja ",
    )
    assert PedidoCreate(**payload).direccion == "Calle QA 123"
    assert PedidoCreate(**(payload | {"latitud": "-12.07123456"})).latitud == Decimal(
        "-12.071235"
    )
    for changes in [
        {"ventana_fin": "2026-10-23T08:00:00-05:00"},
        {"ventana_inicio": "2026-10-23T09:00:00"},
        {"latitud": 91},
        {"longitud": "NaN"},
        {"cliente_nombre": " "},
        {"peso_kg": -1},
    ]:
        with pytest.raises(ValidationError):
            PedidoCreate(**(payload | changes))
    with pytest.raises(ValidationError):
        RutaCreate(
            vehiculo_id=uuid.uuid4(),
            repartidor_id=uuid.uuid4(),
            inicio_planificado="2026-10-23T09:00:00-05:00",
            pedidos=[uuid.UUID(int=1)] * 2,
        )


@pytest.mark.parametrize(
    "status,body",
    [
        (200, b'{"valid":true}'),
        (302, b""),
        (500, b"{}"),
        (200, b"not-json"),
        (200, b"x" * 50),
    ],
)
def test_provider_http_status_json_size_and_redirects(status, body):
    transport = httpx.MockTransport(
        lambda request: httpx.Response(status, content=body)
    )
    original = httpx.Client
    with (
        patch.object(
            provider_http.httpx,
            "Client",
            side_effect=lambda **kw: original(transport=transport, **kw),
        ),
        patch.object(provider_http, "MAX_RESPONSE_BYTES", 40),
    ):
        if status == 200 and body == b'{"valid":true}':
            assert provider_http.fetch_json("https://provider.example") == {
                "valid": True
            }
        else:
            with pytest.raises((ValueError, httpx.HTTPStatusError)):
                provider_http.fetch_json("https://provider.example")


@pytest.mark.parametrize(
    "data",
    [
        {},
        {"code": "NoRoute"},
        {"code": "Ok", "routes": []},
        {
            "code": "Ok",
            "routes": [{"geometry": {"type": "Point", "coordinates": [1, 2]}}],
        },
        {
            "code": "Ok",
            "routes": [
                {
                    "geometry": {
                        "type": "LineString",
                        "coordinates": [[-75, -12], [-75, 91]],
                    }
                }
            ],
        },
        {
            "code": "Ok",
            "routes": [
                {
                    "geometry": {
                        "type": "LineString",
                        "coordinates": [[-75, -12], [-75, -12.1]],
                    },
                    "distance": -1,
                    "duration": 1,
                }
            ],
        },
    ],
)
def test_bad_routing_provider_rolls_back_with_safe_error(data):
    with patch.object(routing, "fetch_json", return_value=data):
        with pytest.raises(HTTPException) as error:
            routing.compute_route([(-12, -75), (-12.1, -75)])
        assert error.value.status_code == 503


def test_schedule_zero_duration_and_legacy_updates():
    from datetime import time

    driver = SimpleNamespace(
        disponible_desde=time(8), disponible_hasta=time(17), repartidor_id=uuid.uuid4()
    )
    vehicle = SimpleNamespace(vehiculo_id=uuid.uuid4())
    start = datetime(2026, 10, 23, 13, tzinfo=timezone.utc)
    db = SimpleNamespace(
        scalars=lambda query: [
            SimpleNamespace(inicio_planificado=None, fin_planificado=None)
        ]
    )
    with pytest.raises(HTTPException) as error:
        scheduling.schedule(db, driver, vehicle, start, 0, 1, 0)
    assert error.value.status_code == 422
    assert (
        scheduling.schedule(db, driver, vehicle, start, 10, 1, 5, uuid.uuid4())[1]
        > start
    )


@pytest.mark.parametrize(
    "address",
    [
        "missing-at.example",
        "@example.test",
        "qa@",
        "qa@@example.test",
        "qa@example",
        "qa@example..test",
        "qa@.example.test",
        "qa@example.test.",
        "qa name@example.test",
        "qa@example.test " + "a" * 100,
    ],
)
def test_email_validation_uses_bounded_linear_parsing(address):
    with pytest.raises(ValueError):
        RepartidorCreate.validar_correo(address)


def test_email_normalizes_and_allows_optional_profile_email():
    assert RepartidorCreate.validar_correo(None) is None
    assert (
        RepartidorCreate.validar_correo(" QA.Name+demo@EXAMPLE.TEST ")
        == "qa.name+demo@example.test"
    )


def test_cors_headers_cover_errors_returned_by_inner_middleware():
    with TestClient(app) as client:
        for response in [
            client.get(
                "/api/v1/vehicles/", headers={"Origin": "http://localhost:8080"}
            ),
            client.post(
                "/api/v1/orders/",
                content=b"x" * 65537,
                headers={"Origin": "http://localhost:8080"},
            ),
            client.get(
                "/api/v1/health",
                headers={"Origin": "http://localhost:8080", "Host": "invalid.example"},
            ),
        ]:
            assert response.status_code in (400, 401, 413)
            assert (
                response.headers["access-control-allow-origin"]
                == "http://localhost:8080"
            )
