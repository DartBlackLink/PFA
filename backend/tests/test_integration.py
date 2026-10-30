"""Integration suite against an isolated Docker API/PostgreSQL, never the user DB.
Run inside the revision container: python /tmp/test_integration.py.
"""

import json, math, unittest, uuid
from datetime import datetime, timedelta, timezone
from urllib.request import Request, urlopen
from urllib.error import HTTPError
from urllib.parse import urlencode
from concurrent.futures import ThreadPoolExecutor
from sqlalchemy import select
from app.core.config import get_settings
from app.core.security import get_password_hash
from app.db.session import SessionLocal
from app.models.entities import Usuario, ControlAcceso, Ruta
import jwt
from fastapi.testclient import TestClient
from app.main import app


def call(path, method="GET", body=None, token=None, form=False):
    headers = {"Authorization": "Bearer " + token} if token else {}
    with TestClient(app) as client:
        response = client.request(
            method,
            "/api/v1" + path,
            headers=headers,
            data=body if form else None,
            json=body if not form else None,
        )
    return response.status_code, response.json(), response.headers


class Integration(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        assert get_settings().database_url.endswith(
            "/ecologistica_revision_20261007"
        ), "Refusing to test user DB"
        cls.suffix = uuid.uuid4().hex[:10]
        cls.email = f"qa.{cls.suffix}@example.test"
        cls.password = "Testing123!"
        with SessionLocal() as db:
            db.add(
                Usuario(
                    email=cls.email,
                    password_hash=get_password_hash(cls.password),
                    rol="ADMIN",
                    estado="ACTIVO",
                )
            )
            db.commit()
        status, data, _ = call(
            "/auth/login",
            "POST",
            {"username": cls.email, "password": cls.password},
            form=True,
        )
        assert status == 200
        cls.admin = data["access_token"]

    def driver(self):
        ident = uuid.uuid4().int % 100000000
        body = {
            "nombre": "Conductor QA",
            "dni": f"{ident:08d}",
            "licencia": "LIC-TEST-99",
            "categoria_licencia": "A-IIb",
            "anios_experiencia": 4,
            "contacto": "987654321",
            "disponible_desde": "08:00",
            "disponible_hasta": "17:00",
            "origen_latitud": -12.06,
            "origen_longitud": -75.20,
            "correo": f"driver.{uuid.uuid4().hex}@example.test",
            "password": self.password,
            "estado": "ACTIVO",
        }
        status, item, _ = call("/drivers/", "POST", body, self.admin)
        self.assertEqual(status, 201, item)
        status, data, _ = call(
            "/auth/login",
            "POST",
            {"username": body["correo"], "password": self.password},
            form=True,
        )
        self.assertEqual(status, 200)
        return body, item, data["access_token"]

    def test_01_login_delays_and_reset(self):
        email = f"lock.{uuid.uuid4().hex}@example.test"
        with SessionLocal() as db:
            db.add(
                Usuario(
                    email=email,
                    password_hash=get_password_hash(self.password),
                    rol="ADMIN",
                    estado="ACTIVO",
                )
            )
            db.commit()

        def login(password):
            return call(
                "/auth/login",
                "POST",
                {"username": email, "password": password},
                form=True,
            )

        self.assertEqual(login("wrong")[0], 401)
        self.assertEqual(login("wrong")[0], 401)
        for expected in [5, 10, 300, 300]:
            status, _, headers = login("wrong")
            self.assertEqual(status, 429)
            self.assertEqual(int(headers["Retry-After"]), expected)
            with SessionLocal() as db:
                # Test identity is unique, the row is the last state created here.
                import hashlib, hmac

                key = hmac.new(
                    get_settings().secret_key.encode(), email.encode(), hashlib.sha256
                ).hexdigest()
                control = db.get(ControlAcceso, key)
                count = control.intentos_fallidos
                deadline = control.bloqueo_hasta
            self.assertEqual(login(self.password)[0], 429)
            self.assertEqual(login("wrong")[0], 429)
            with SessionLocal() as db:
                control = db.get(ControlAcceso, key)
                self.assertEqual(control.intentos_fallidos, count)
                self.assertEqual(control.bloqueo_hasta, deadline)
                # Controlled expired deadline; tests do not wait 5 minutes.
                control.bloqueo_hasta = datetime.now(timezone.utc) - timedelta(
                    seconds=1
                )
                db.commit()
        self.assertEqual(login(self.password)[0], 200)
        self.assertEqual(login("wrong")[0], 401)
        with SessionLocal() as db:
            self.assertEqual(db.get(ControlAcceso, key).intentos_fallidos, 1)

    def test_02_unknown_identity_and_concurrency(self):
        email = f"unknown.{uuid.uuid4().hex}@example.test"

        def attempt(_):
            return call(
                "/auth/login", "POST", {"username": email, "password": "bad"}, form=True
            )[0]

        with ThreadPoolExecutor(max_workers=6) as pool:
            statuses = list(pool.map(attempt, range(6)))
        self.assertEqual(statuses.count(401), 2)
        self.assertEqual(statuses.count(429), 4)

    def test_03_session_expiry_and_rbac(self):
        self.assertEqual(call("/auth/me", token=self.admin)[0], 200)
        self.assertEqual(call("/vehicles/")[0], 401)
        _, _, driver = self.driver()
        self.assertEqual(call("/vehicles/", token=driver)[0], 403)
        self.assertEqual(call("/drivers/", token=driver)[0], 403)
        self.assertEqual(call("/drivers/me", token=driver)[0], 200)
        token = jwt.encode(
            {
                "sub": self.email,
                "exp": datetime.now(timezone.utc) - timedelta(seconds=1),
                "rol": "ADMIN",
            },
            get_settings().secret_key,
            algorithm=get_settings().algorithm,
        )
        self.assertEqual(call("/auth/me", token=token)[0], 401)

    def test_04_vehicle_crud_validation(self):
        body = {
            "placa": "qa-" + uuid.uuid4().hex[:8],
            "tipo": "Camioneta",
            "capacidad_kg": 800,
            "consumo_km_l": 10,
            "factor_emision_kg_km": 0.18,
            "anio_fabricacion": 2024,
            "estado": "ACTIVO",
        }
        status, item, _ = call("/vehicles/", "POST", body, self.admin)
        self.assertEqual(status, 201, item)
        self.assertEqual(item["placa"], body["placa"].upper())
        self.assertEqual(call("/vehicles/", "POST", body, self.admin)[0], 409)
        for field in ["capacidad_kg", "consumo_km_l"]:
            self.assertEqual(
                call("/vehicles/", "POST", {**body, field: 0}, self.admin)[0], 422
            )
        status, item, _ = call(
            "/vehicles/" + item["vehiculo_id"],
            "PUT",
            {**body, "estado": "INACTIVO"},
            self.admin,
        )
        self.assertEqual(status, 200)
        self.assertEqual(item["estado"], "INACTIVO")

    def test_05_driver_fields_update_and_disable(self):
        body, item, token = self.driver()
        for field in ["dni", "licencia", "contacto"]:
            self.assertEqual(item[field], body[field])
        self.assertTrue(item["disponible_desde"].startswith("08:00"))
        self.assertEqual(call("/drivers/", "POST", body, self.admin)[0], 409)
        self.assertEqual(
            call(
                "/drivers/", "POST", {**body, "disponible_hasta": "07:00"}, self.admin
            )[0],
            422,
        )
        status, item, _ = call(
            "/drivers/" + item["repartidor_id"],
            "PUT",
            {**body, "contacto": "912345678", "estado": "INACTIVO"},
            self.admin,
        )
        self.assertEqual(status, 200, item)
        self.assertEqual(item["contacto"], "912345678")
        self.assertEqual(call("/auth/me", token=token)[0], 401)

    def test_06_route_owner_isolation(self):
        _, one, t1 = self.driver()
        _, two, t2 = self.driver()
        vehicle = {
            "placa": "rt-" + uuid.uuid4().hex[:8],
            "tipo": "Moto",
            "capacidad_kg": 50,
            "consumo_km_l": 20,
            "factor_emision_kg_km": 0.1,
            "anio_fabricacion": 2025,
        }
        status, v, _ = call("/vehicles/", "POST", vehicle, self.admin)
        self.assertEqual(status, 201)
        with SessionLocal() as db:
            a = Ruta(
                vehiculo_id=v["vehiculo_id"],
                repartidor_id=one["repartidor_id"],
                algoritmo="QA",
                estado="PLANIFICADA",
            )
            b = Ruta(
                vehiculo_id=v["vehiculo_id"],
                repartidor_id=two["repartidor_id"],
                algoritmo="QA",
                estado="PLANIFICADA",
            )
            db.add_all([a, b])
            db.commit()
            ids = {str(a.ruta_id), str(b.ruta_id)}
        s, r, _ = call("/routes/", token=t1)
        self.assertEqual(s, 200)
        self.assertEqual(len(r), 1)
        self.assertEqual(r[0]["repartidor_id"], one["repartidor_id"])
        s, r, _ = call("/routes/", token=t2)
        self.assertEqual(len(r), 1)
        self.assertEqual(r[0]["repartidor_id"], two["repartidor_id"])
        s, r, _ = call("/routes/", token=self.admin)
        self.assertTrue(ids.issubset({x["ruta_id"] for x in r}))

    def test_07_orders_validation_and_persistence(self):
        body = {
            "cliente_nombre": "Cliente QA",
            "direccion": "Av. Prueba 123",
            "latitud": -12.07,
            "longitud": -75.21,
            "peso_kg": 2.5,
            "tipo_producto": "GENERAL",
            "prioridad": "ALTA",
            "ventana_inicio": "2026-10-08T13:00:00Z",
            "ventana_fin": "2026-10-08T15:00:00Z",
        }
        status, item, _ = call("/orders/", "POST", body, self.admin)
        self.assertEqual(status, 201, item)
        status, items, _ = call("/orders/?limit=1000", token=self.admin)
        self.assertEqual(status, 200)
        saved = next(e for e in items if e["pedido_id"] == item["pedido_id"])
        self.assertEqual(saved["cliente_nombre"], body["cliente_nombre"])
        self.assertEqual(float(saved["peso_kg"]), 2.5)
        invalid = dict(body, ventana_fin=body["ventana_inicio"])
        self.assertEqual(call("/orders/", "POST", invalid, self.admin)[0], 422)
        self.assertEqual(
            call("/orders/", "POST", dict(body, peso_kg=0), self.admin)[0], 422
        )
        self.assertEqual(
            call(
                "/orders/", "POST", dict(body, cliente_id=str(uuid.uuid4())), self.admin
            )[0],
            422,
        )

    def test_10_destination_validation_and_lookup_permissions(self):
        body = {
            "cliente_nombre": "Ubicacion QA",
            "direccion": "  Calle Real 123, Huancayo  ",
            "latitud": -12.07,
            "longitud": -75.21,
            "peso_kg": 2,
            "tipo_producto": "GENERAL",
            "ventana_inicio": "2026-10-10T13:00:00Z",
            "ventana_fin": "2026-10-10T15:00:00Z",
        }
        code, item, _ = call("/orders/", "POST", body, self.admin)
        self.assertEqual(code, 201, item)
        self.assertEqual(item["direccion"], body["direccion"].strip())
        self.assertEqual(float(item["latitud"]), body["latitud"])
        self.assertEqual(float(item["longitud"]), body["longitud"])
        for change in [
            dict(latitud=None),
            dict(longitud=None),
            dict(direccion="   abc   "),
            dict(estado="ENTREGADO"),
            dict(longitud=181),
            dict(ventana_inicio="2026-10-10T13:00:00"),
        ]:
            self.assertEqual(
                call("/orders/", "POST", dict(body, **change), self.admin)[0],
                422,
                change,
            )
        self.assertEqual(call("/locations/search?q=Huancayo")[0], 401)
        _, _, driver = self.driver()
        self.assertEqual(call("/locations/search?q=Huancayo", token=driver)[0], 403)
        self.assertEqual(call("/locations/search?q=a", token=self.admin)[0], 422)
        self.assertEqual(
            call("/locations/reverse?lat=91&lon=0", token=self.admin)[0], 422
        )

    def test_08_assignment_map_details_and_ownership(self):
        import threading
        from http.server import HTTPServer, BaseHTTPRequestHandler

        class RoutingStub(BaseHTTPRequestHandler):
            def log_message(self, *args):
                pass

            def do_GET(self):
                coordinates = [
                    [float(n) for n in point.split(",")]
                    for point in self.path.split("/")[-1].split("?")[0].split(";")
                ]
                body = json.dumps(
                    {
                        "code": "Ok",
                        "routes": [
                            {
                                "geometry": {
                                    "type": "LineString",
                                    "coordinates": coordinates,
                                },
                                "distance": 2500,
                                "duration": 600,
                            }
                        ],
                    }
                ).encode()
                self.send_response(200)
                self.send_header("Content-Type", "application/json")
                self.end_headers()
                self.wfile.write(body)

        server = HTTPServer(("127.0.0.1", 8090), RoutingStub)
        thread = threading.Thread(target=server.serve_forever, daemon=True)
        thread.start()
        try:
            _, driver, token = self.driver()
            _, _, other = self.driver()
            body = {
                "placa": "mp-" + uuid.uuid4().hex[:8],
                "tipo": "Camioneta",
                "capacidad_kg": 50,
                "consumo_km_l": 12,
                "factor_emision_kg_km": 0.1,
                "anio_fabricacion": 2025,
            }
            status, vehicle, _ = call("/vehicles/", "POST", body, self.admin)
            self.assertEqual(status, 201)
            order_body = {
                "cliente_nombre": "Entrega QA",
                "direccion": "Av. Ejemplo 123",
                "peso_kg": 4,
                "tipo_producto": "GENERAL",
                "prioridad": "ALTA",
                "ventana_inicio": "2026-10-08T13:00:00Z",
                "ventana_fin": "2026-10-08T15:00:00Z",
                "latitud": -12.07,
                "longitud": -75.21,
                "punto_referencia": "Puerta de prueba",
            }
            status, order, _ = call("/orders/", "POST", order_body, self.admin)
            self.assertEqual(status, 201)
            payload = {
                "inicio_planificado": "2026-10-08T13:00:00Z",
                "vehiculo_id": vehicle["vehiculo_id"],
                "repartidor_id": driver["repartidor_id"],
                "pedidos": [order["pedido_id"]],
            }
            self.assertEqual(call("/routes/", "POST", payload, token)[0], 403)
            self.assertEqual(
                call("/orders/", "POST", dict(order_body, latitud=91), self.admin)[0],
                422,
            )
            self.assertEqual(
                call(
                    "/routes/",
                    "POST",
                    dict(payload, pedidos=[order["pedido_id"], order["pedido_id"]]),
                    self.admin,
                )[0],
                422,
            )
            status, route, _ = call("/routes/", "POST", payload, self.admin)
            self.assertEqual(status, 201, route)
            self.assertEqual(float(route["distancia_km"]), 2.5)
            self.assertEqual(float(route["tiempo_min"]), 10)
            self.assertEqual(route["geometria"]["type"], "LineString")
            self.assertEqual(route["geometria"]["coordinates"][0], [-75.2, -12.06])
            self.assertEqual(route["entregas"][0]["pedido_id"], order["pedido_id"])
            self.assertEqual(
                route["entregas"][0]["punto_referencia"], "Puerta de prueba"
            )
            self.assertEqual(call("/routes/" + route["ruta_id"], token=token)[0], 200)
            self.assertEqual(call("/routes/" + route["ruta_id"], token=other)[0], 404)
            self.assertEqual(call("/routes/", "POST", payload, self.admin)[0], 409)
            status, orders, _ = call("/orders/?limit=1000", token=self.admin)
            self.assertEqual(
                next(o for o in orders if o["pedido_id"] == order["pedido_id"])[
                    "estado"
                ],
                "ASIGNADO",
            )
            status, missing, _ = call("/orders/", "POST", order_body, self.admin)
            # Simulate a historical row without a destination; new records reject it.
            from app.models.entities import Pedido

            with SessionLocal() as db:
                legacy = db.get(Pedido, uuid.UUID(missing["pedido_id"]))
                legacy.latitud = None
                legacy.longitud = None
                db.commit()
            self.assertEqual(
                call(
                    "/routes/",
                    "POST",
                    dict(payload, pedidos=[missing["pedido_id"]]),
                    self.admin,
                )[0],
                422,
            )
            status, heavy, _ = call(
                "/orders/", "POST", dict(order_body, peso_kg=51), self.admin
            )
            self.assertEqual(
                call(
                    "/routes/",
                    "POST",
                    dict(payload, pedidos=[heavy["pedido_id"]]),
                    self.admin,
                )[0],
                422,
            )
            status, second, _ = call("/orders/", "POST", order_body, self.admin)
            with ThreadPoolExecutor(max_workers=2) as pool:
                results = list(
                    pool.map(
                        lambda _: call(
                            "/routes/",
                            "POST",
                            dict(
                                payload,
                                pedidos=[second["pedido_id"]],
                                inicio_planificado="2026-10-08T14:00:00Z",
                            ),
                            self.admin,
                        )[0],
                        range(2),
                    )
                )
            self.assertEqual(sorted(results), [201, 409])
        finally:
            server.shutdown()
            server.server_close()
            thread.join()
        status, pending, _ = call("/orders/", "POST", order_body, self.admin)
        self.assertEqual(
            call(
                "/routes/",
                "POST",
                dict(payload, pedidos=[pending["pedido_id"]]),
                self.admin,
            )[0],
            503,
        )
        status, orders, _ = call("/orders/?limit=1000", token=self.admin)
        self.assertEqual(
            next(o for o in orders if o["pedido_id"] == pending["pedido_id"])["estado"],
            "PENDIENTE",
        )

    def test_09_schedule_shift_duration_conflicts_and_legacy(self):
        import threading
        from http.server import HTTPServer, BaseHTTPRequestHandler
        from app.models.entities import Repartidor

        class Stub(BaseHTTPRequestHandler):
            def log_message(self, *args):
                pass

            def do_GET(self):
                coords = [
                    [float(n) for n in point.split(",")]
                    for point in self.path.split("/")[-1].split("?")[0].split(";")
                ]
                body = json.dumps(
                    {
                        "code": "Ok",
                        "routes": [
                            {
                                "geometry": {
                                    "type": "LineString",
                                    "coordinates": coords,
                                },
                                "distance": 2500,
                                "duration": 600,
                            }
                        ],
                    }
                ).encode()
                self.send_response(200)
                self.end_headers()
                self.wfile.write(body)

        server = HTTPServer(("127.0.0.1", 8090), Stub)
        thread = threading.Thread(target=server.serve_forever, daemon=True)
        thread.start()
        try:
            _, driver, token = self.driver()
            _, other_driver, _ = self.driver()

            def vehicle():
                status, item, _ = call(
                    "/vehicles/",
                    "POST",
                    {
                        "placa": "hr-" + uuid.uuid4().hex[:8],
                        "tipo": "Furgon",
                        "capacidad_kg": 500,
                        "consumo_km_l": 12,
                        "factor_emision_kg_km": 0.1,
                        "anio_fabricacion": 2025,
                    },
                    self.admin,
                )
                self.assertEqual(status, 201, item)
                return item

            v = vehicle()
            v2 = vehicle()

            def order():
                status, item, _ = call(
                    "/orders/",
                    "POST",
                    {
                        "cliente_nombre": "Horario QA",
                        "direccion": "Av. Horario 123",
                        "peso_kg": 4,
                        "tipo_producto": "GENERAL",
                        "prioridad": "ALTA",
                        "ventana_inicio": "2026-10-10T12:00:00Z",
                        "ventana_fin": "2026-10-10T23:00:00Z",
                        "latitud": -12.07,
                        "longitud": -75.21,
                    },
                    self.admin,
                )
                self.assertEqual(status, 201, item)
                return item["pedido_id"]

            pending = order()
            payload = {
                "repartidor_id": driver["repartidor_id"],
                "vehiculo_id": v["vehiculo_id"],
                "pedidos": [pending],
                "inicio_planificado": "2026-10-10T08:00:00-05:00",
            }
            self.assertEqual(
                call(
                    "/routes/",
                    "POST",
                    {k: v for k, v in payload.items() if k != "inicio_planificado"},
                    self.admin,
                )[0],
                422,
            )
            self.assertEqual(
                call(
                    "/routes/",
                    "POST",
                    dict(payload, inicio_planificado="2026-10-10T08:00:00"),
                    self.admin,
                )[0],
                422,
            )
            self.assertEqual(
                call(
                    "/routes/",
                    "POST",
                    dict(payload, inicio_planificado="2026-10-10T07:59:00-05:00"),
                    self.admin,
                )[0],
                422,
            )
            self.assertEqual(
                call(
                    "/routes/",
                    "POST",
                    dict(payload, inicio_planificado="2026-10-10T16:50:00-05:00"),
                    self.admin,
                )[0],
                422,
            )
            status, r, _ = call("/routes/", "POST", payload, self.admin)
            self.assertEqual(status, 201, r)
            self.assertEqual(
                datetime.fromisoformat(r["fin_planificado"])
                - datetime.fromisoformat(r["inicio_planificado"]),
                timedelta(minutes=15),
            )
            self.assertEqual(
                call(
                    "/routes/" + r["ruta_id"] + "/horario",
                    "PUT",
                    {"inicio_planificado": "2026-10-10T10:00:00-05:00"},
                    token,
                )[0],
                403,
            )
            next_order = order()
            next_payload = dict(
                payload,
                pedidos=[next_order],
                inicio_planificado="2026-10-10T08:10:00-05:00",
            )
            self.assertEqual(
                call(
                    "/routes/",
                    "POST",
                    dict(next_payload, vehiculo_id=v2["vehiculo_id"]),
                    self.admin,
                )[0],
                409,
            )  # same driver
            self.assertEqual(
                call(
                    "/routes/",
                    "POST",
                    dict(next_payload, repartidor_id=other_driver["repartidor_id"]),
                    self.admin,
                )[0],
                409,
            )  # same vehicle
            status, orders, _ = call("/orders/?limit=1000", token=self.admin)
            self.assertEqual(
                next(o for o in orders if o["pedido_id"] == next_order)["estado"],
                "PENDIENTE",
            )
            status, r2, _ = call(
                "/routes/",
                "POST",
                dict(next_payload, inicio_planificado="2026-10-10T08:15:00-05:00"),
                self.admin,
            )
            self.assertEqual(status, 201, r2)  # adjacent permitted
            status, _, _ = call(
                "/routes/" + r2["ruta_id"] + "/horario",
                "PUT",
                {"inicio_planificado": "2026-10-10T08:05:00-05:00"},
                self.admin,
            )
            self.assertEqual(status, 409)
            status, _, _ = call(
                "/routes/" + r2["ruta_id"] + "/horario",
                "PUT",
                {"inicio_planificado": "2026-10-10T09:00:00-05:00"},
                self.admin,
            )
            self.assertEqual(status, 200)
            # Historical routes have no inferred dates; they block new allocation until regularized.
            with SessionLocal() as db:
                legacy = db.get(Ruta, uuid.UUID(r["ruta_id"]))
                legacy.inicio_planificado = None
                legacy.fin_planificado = None
                legacy.servicio_min_por_entrega = None
                db.commit()
            self.assertEqual(
                call(
                    "/routes/",
                    "POST",
                    dict(
                        payload,
                        pedidos=[order()],
                        inicio_planificado="2026-10-10T10:00:00-05:00",
                    ),
                    self.admin,
                )[0],
                409,
            )
            self.assertEqual(
                call(
                    "/routes/" + r["ruta_id"] + "/horario",
                    "PUT",
                    {"inicio_planificado": "2026-10-10T08:00:00-05:00"},
                    self.admin,
                )[0],
                200,
            )
            # Distinct orders competing for the same resources/time: exactly one succeeds.
            candidates = [
                dict(
                    payload,
                    pedidos=[order()],
                    inicio_planificado="2026-10-10T11:00:00-05:00",
                )
                for _ in range(2)
            ]
            with ThreadPoolExecutor(max_workers=2) as pool:
                codes = list(
                    pool.map(
                        lambda body: call("/routes/", "POST", body, self.admin)[0],
                        candidates,
                    )
                )
            self.assertEqual(sorted(codes), [201, 409])
            with SessionLocal() as db:
                d = db.get(Repartidor, uuid.UUID(driver["repartidor_id"]))
                d.disponible_desde = None
                d.disponible_hasta = None
                db.commit()
            self.assertEqual(
                call(
                    "/routes/",
                    "POST",
                    dict(
                        payload,
                        pedidos=[order()],
                        inicio_planificado="2026-10-10T12:00:00-05:00",
                    ),
                    self.admin,
                )[0],
                422,
            )
        finally:
            server.shutdown()
            server.server_close()
            thread.join()


if __name__ == "__main__":
    unittest.main(verbosity=2)
