"""Operation regression against PostgreSQL, reusing the real auth and route API."""
import uuid
from fastapi.testclient import TestClient
from sqlalchemy import select
from app.main import app
from app.db.session import SessionLocal
from app.models.entities import Pedido, Ruta, Usuario
from app.core.security import get_password_hash
from test_optimization_api import api_case, preview


def setup_route(api_case):
    admin, payload, driver, _, password = api_case
    plan = preview(admin, payload)
    confirmed = admin.post(f"/api/v1/optimizations/{plan['plan_id']}/confirm")
    assert confirmed.status_code == 200
    identifier = confirmed.json()['ruta_ids'][0]
    courier = TestClient(app)
    response = courier.post('/api/v1/auth/login', data={'username': driver['correo'], 'password': password})
    assert response.status_code == 200
    courier.headers['Authorization'] = 'Bearer ' + response.json()['access_token']
    return admin, courier, identifier


def test_gold_real_operation_is_idempotent_and_visible_to_admin(api_case):
    admin, courier, identifier = setup_route(api_case)
    base = '/api/v1/routes/' + identifier
    route = courier.get(base).json()
    orders = [r['pedido_id'] for r in route['entregas']]
    assert courier.post(base + f'/entregas/{orders[0]}/confirmar').status_code == 409
    started = courier.post(base + '/iniciar')
    assert started.status_code == 200, started.text
    assert started.json()['estado'] == 'EN_CURSO' and started.json()['iniciado_en']
    assert courier.post(base + '/iniciar').json()['iniciado_en'] == started.json()['iniciado_en']
    assert courier.post(base + f'/entregas/{orders[1]}/confirmar').status_code == 409
    event = {'evento_id': str(uuid.uuid4()), 'tipo': 'AVERIA', 'descripcion': 'QA: revisión de vehículo sin daño real.'}
    first = courier.post(base + '/incidentes', json=event)
    assert first.status_code == 200, first.text
    assert courier.post(base + '/incidentes', json=event).json() == first.json()
    assert len(admin.get(base + '/incidentes').json()) == 1
    assert courier.post(base + '/incidentes', json={**event, 'descripcion':'Intento de cambiar evento registrado'}).status_code == 409
    for order in orders:
        delivered = courier.post(base + f'/entregas/{order}/confirmar')
        assert delivered.status_code == 200, delivered.text
        when = next(d['entregado_en'] for d in delivered.json()['entregas'] if d['pedido_id'] == order)
        repeated = courier.post(base + f'/entregas/{order}/confirmar')
        assert next(d['entregado_en'] for d in repeated.json()['entregas'] if d['pedido_id'] == order) == when
    final = admin.get(base).json()
    assert final['estado'] == 'FINALIZADA' and final['finalizado_en']
    with SessionLocal() as db:
        assert db.get(Ruta, uuid.UUID(identifier)).estado == 'FINALIZADA'
        assert all(db.get(Pedido, uuid.UUID(o)).estado == 'ENTREGADO' for o in orders)
    assert courier.post(base + '/iniciar').status_code == 409
    assert courier.post(base + '/incidentes', json={**event, 'evento_id':str(uuid.uuid4())}).status_code == 409
    assert admin.post(base + '/iniciar').status_code == 403


def test_operational_permissions_and_invalid_incident_do_not_write(api_case):
    _, courier, identifier = setup_route(api_case)
    base = '/api/v1/routes/' + identifier
    alien = str(uuid.uuid4())
    assert courier.post('/api/v1/routes/'+alien+'/iniciar').status_code == 404
    assert courier.post(base+'/entregas/'+alien+'/confirmar').status_code == 404
    assert courier.post(base+'/incidentes', json={'evento_id':alien,'tipo':'INVALID','descripcion':' '}).status_code == 422
    with TestClient(app) as anonymous:
        assert anonymous.get(base).status_code == 401
        assert anonymous.post(base+'/iniciar').status_code == 401
    password = uuid.uuid4().hex
    email = uuid.uuid4().hex+'@example.test'
    with SessionLocal() as db:
        db.add(Usuario(email=email,password_hash=get_password_hash(password),rol='REPARTIDOR',estado='ACTIVO'))
        db.commit()
    with TestClient(app) as other:
        login=other.post('/api/v1/auth/login',data={'username':email,'password':password})
        other.headers['Authorization']='Bearer '+login.json()['access_token']
        assert other.get(base).status_code == 404
        assert other.get(base+'/incidentes').status_code == 404
        assert other.post(base+'/iniciar').status_code == 404
        assert other.post(base+'/entregas/'+alien+'/confirmar').status_code == 404
        assert other.post(base+'/incidentes',json={'evento_id':alien,'tipo':'AVERIA','descripcion':'Acceso ajeno de prueba'}).status_code == 404


def test_resource_preflight_reports_unknown_schedule(api_case):
    client, payload, driver, vehicle, _ = api_case
    with SessionLocal() as db:
        route=Ruta(vehiculo_id=uuid.UUID(vehicle['vehiculo_id']),repartidor_id=uuid.UUID(driver['repartidor_id']),algoritmo='LEGACY_QA',estado='PLANIFICADA')
        db.add(route)
        db.commit()
        identifier=str(route.ruta_id)
    response=client.get('/api/v1/optimizations/resources')
    assert response.status_code == 200
    assert any(row['ruta_id']==identifier for row in response.json())
    denied=client.post('/api/v1/optimizations/preview',json=payload)
    assert denied.status_code == 409


def test_cancel_preview_retains_orders_and_rejects_confirmation(api_case):
    client, payload, *_ = api_case
    plan = preview(client, payload)
    path = '/api/v1/optimizations/'+plan['plan_id']
    assert client.post(path+'/cancel').json()['estado'] == 'CANCELADO'
    assert client.post(path+'/cancel').json()['estado'] == 'CANCELADO'
    assert client.post(path+'/confirm').status_code == 409
    with SessionLocal() as db:
        assert all(db.get(Pedido,uuid.UUID(i)).estado=='PENDIENTE' for i in payload['pedidos'])


def test_changed_address_invalidates_preview(api_case):
    client,payload,*_=api_case
    plan=preview(client,payload)
    with SessionLocal() as db:
        order=db.get(Pedido,uuid.UUID(payload['pedidos'][0]))
        order.direccion='Destino corregido después de calcular'
        db.commit()
    assert client.post('/api/v1/optimizations/'+plan['plan_id']+'/confirm').status_code==409
