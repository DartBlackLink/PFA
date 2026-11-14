"""Order editing preserves route and customer consistency."""
from test_optimization_api import api_case, preview

def body(client, identifier):
    item = next(p for p in client.get("/api/v1/orders/?limit=1000").json() if p["pedido_id"] == identifier)
    return {k: item[k] for k in (
        "cliente_id", "direccion", "latitud", "longitud", "punto_referencia",
        "peso_kg", "ventana_inicio", "ventana_fin", "prioridad", "tipo_producto"
    )}

def test_pending_order_edit_invalidates_old_preview(api_case):
    client, request, _, _, _ = api_case
    identifier = request["pedidos"][0]
    plan = preview(client, request)
    payload = body(client, identifier)
    response = client.put("/api/v1/orders/" + identifier, json={**payload, "peso_kg": 6})
    assert response.status_code == 200, response.text
    assert float(body(client, identifier)["peso_kg"]) == 6
    assert client.post("/api/v1/optimizations/" + plan["plan_id"] + "/confirm").status_code == 409
    assert client.put("/api/v1/orders/" + identifier, json={**payload, "peso_kg": 0}).status_code == 422
    assert float(body(client, identifier)["peso_kg"]) == 6

def test_assigned_order_edit_is_rejected(api_case):
    client, request, _, _, _ = api_case
    identifier = request["pedidos"][0]
    plan = preview(client, request)
    assert client.post("/api/v1/optimizations/" + plan["plan_id"] + "/confirm").status_code == 200
    payload = body(client, identifier)
    response = client.put("/api/v1/orders/" + identifier, json={**payload, "peso_kg": 4})
    assert response.status_code == 409
    assert float(body(client, identifier)["peso_kg"]) == 5


def test_cancelled_route_preserves_history_and_allows_new_plan(api_case):
    client, request, _, _, _ = api_case
    plan = preview(client, request)
    identifier = client.post("/api/v1/optimizations/" + plan["plan_id"] + "/confirm").json()["ruta_ids"][0]
    response = client.post("/api/v1/routes/" + identifier + "/cancelar?version=1")
    assert response.status_code == 200, response.text
    assert response.json()["estado"] == "CANCELADA"
    assert len(response.json()["entregas"]) == 2
    assert client.post("/api/v1/routes/" + identifier + "/cancelar?version=1").json() == response.json()
    pending = client.get("/api/v1/orders/?estado=PENDIENTE&limit=1000").json()
    assert set(request["pedidos"]) <= {p["pedido_id"] for p in pending}
    assert preview(client, request)["rutas"]

def test_road_geometry_outside_area_is_rejected_before_assignment(api_case):
    from unittest.mock import patch
    from app.api.routes import optimization
    client, request, _, _, _ = api_case
    shape = {"type": "LineString", "coordinates": [[-75.21, -12.06], [-75.10, -12.05]]}
    with patch.object(optimization, "road_shape", return_value=(shape, [(1, 2), (1, 2), (1, 2)])):
        response = client.post("/api/v1/optimizations/preview", json=request)
    assert response.status_code == 422, response.text
    assert "zona operativa" in response.json()["detail"]
    assert all(p["estado"] == "PENDIENTE" for p in client.get("/api/v1/orders/?limit=1000").json() if p["pedido_id"] in request["pedidos"])
