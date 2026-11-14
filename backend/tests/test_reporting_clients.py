"""GOLD, happy, unhappy and boundary acceptance on real isolated PostgreSQL."""

import uuid
from decimal import Decimal

from fastapi.testclient import TestClient

from app.db.session import SessionLocal
from app.main import app
from app.models.entities import Ruta, RutaDetalle
from app.services.report_pdf import create_pdf
from app.services.sustainability import aggregate_metric
from test_optimization_api import api_case, preview
from test_route_operation import setup_route


def test_gold_report_from_confirmed_plan_and_pdf(api_case):
    admin, payload, *_ = api_case
    plan = preview(admin, payload)
    confirmed = admin.post(f"/api/v1/optimizations/{plan['plan_id']}/confirm").json()
    rid = confirmed['ruta_ids'][0]
    report = admin.get(f'/api/v1/reports/routes/{rid}')
    assert report.status_code == 200, report.text
    data = report.json()
    assert data['co2_kg'] >= 0 and data['ventanas']['previstas_evaluadas'] == 2
    assert data['ventanas']['cumplimiento_real_pct'] is None
    pdf = admin.get(f'/api/v1/reports/routes/{rid}/pdf')
    assert pdf.status_code == 200 and pdf.content.startswith(b'%PDF-1.4')
    assert pdf.content.rstrip().endswith(b'%%EOF') and rid.encode() in pdf.content
    assert pdf.headers['content-type'] == 'application/pdf'
    assert 'no-store' in pdf.headers['cache-control']
    assert 'attachment;' in pdf.headers['content-disposition']
    assert admin.get('/api/v1/reports/routes?limit=1').json()['items']


def test_report_permissions_and_unknown_or_invalid_route(api_case):
    admin, courier, rid = setup_route(api_case)
    for path in ['/reports/summary', '/reports/routes', f'/reports/routes/{rid}/pdf', '/reports/environment', '/clients/']:
        assert courier.get('/api/v1' + path).status_code == 403
        with TestClient(app) as anonymous:
            assert anonymous.get('/api/v1' + path).status_code == 401
    assert courier.put('/api/v1/reports/environment', json={}).status_code == 403
    assert courier.post('/api/v1/clients/', json={'nombre': 'No autorizado'}).status_code == 403
    assert admin.get('/api/v1/reports/routes/not-a-uuid/pdf').status_code == 422
    assert admin.get(f'/api/v1/reports/routes/{uuid.uuid4()}/pdf').status_code == 404
    with SessionLocal() as db:
        db.get(Ruta, uuid.UUID(rid)).estado = 'CANCELADA'
        db.commit()
    assert admin.get(f'/api/v1/reports/routes/{rid}/pdf').status_code == 409


def test_missing_estimate_is_not_zero_and_environment_is_documented(api_case):
    admin, _, rid = setup_route(api_case)
    assert admin.put('/api/v1/reports/environment', json={}).status_code == 200
    assert admin.get(f'/api/v1/reports/routes/{rid}').json()['equivalencia'] is None
    for body in [{'factor_kg_por_unidad': 0}, {'factor_kg_por_unidad': 2},
                 {'factor_kg_por_unidad': 'NaN', 'unidad': 'QA', 'fuente': 'Fuente QA sintética'},
                 {'factor_kg_por_unidad': -2, 'unidad': 'QA', 'fuente': 'Fuente QA sintética'}]:
        assert admin.put('/api/v1/reports/environment', json=body).status_code == 422
    body = {'factor_kg_por_unidad': 2, 'unidad': 'unidad QA sintética', 'fuente': 'Parámetro sintético únicamente para probar la división; no usar en operación.'}
    assert admin.put('/api/v1/reports/environment', json=body).status_code == 200
    data = admin.get(f'/api/v1/reports/routes/{rid}').json()
    assert data['equivalencia']['valor'] == data['co2_kg'] / 2
    assert 'teórica' in data['equivalencia']['advertencia']
    with SessionLocal() as db:
        db.get(Ruta, uuid.UUID(rid)).co2_kg = None
        db.commit()
    data = admin.get(f'/api/v1/reports/routes/{rid}').json()
    assert data['co2_kg'] is None and data['equivalencia'] is None
    assert admin.put('/api/v1/reports/environment', json={}).status_code == 200
    assert aggregate_metric([Decimal('0'), None])['valor'] is None
    assert aggregate_metric([])['valor'] is None
    assert aggregate_metric([Decimal('0')])['valor'] == 0


def test_real_window_compliance_and_summary(api_case):
    admin, _, rid = setup_route(api_case)
    from datetime import timedelta
    from app.models.entities import Pedido
    with SessionLocal() as db:
        rows = db.query(RutaDetalle).filter(RutaDetalle.ruta_id == uuid.UUID(rid)).order_by(RutaDetalle.secuencia).all()
        for i, detail in enumerate(rows):
            order = db.get(Pedido, detail.pedido_id)
            detail.estado_entrega = 'ENTREGADO'
            detail.entregado_en = order.ventana_inicio if i == 0 else order.ventana_fin + timedelta(seconds=1)
        db.commit()
    data = admin.get(f'/api/v1/reports/routes/{rid}').json()['ventanas']
    assert data['reales_evaluadas'] == 2 and data['cumplimiento_real_pct'] == 50
    assert admin.get('/api/v1/reports/summary').status_code == 200
    assert admin.get('/api/v1/reports/routes?limit=101').status_code == 422


def test_client_preferences_gold_update_clear_and_invalid(api_case):
    admin = api_case[0]
    created = admin.post('/api/v1/clients/', json={'nombre': '  Cliente QA  ', 'contacto': 'QA'})
    assert created.status_code == 201
    cid = created.json()['cliente_id']
    assert created.json()['nombre'] == 'Cliente QA'
    preference = {'hora_preferida_inicio': '09:00', 'hora_preferida_fin': '11:00',
                  'punto_referencia': 'Entrada principal QA', 'restriccion_acceso': 'Avisar antes de llegar.'}
    saved = admin.put(f'/api/v1/clients/{cid}/preferences', json=preference)
    assert saved.status_code == 200 and saved.json()['preferencia']['hora_preferida_inicio'] == '09:00:00'
    assert admin.get(f'/api/v1/clients/{cid}').json()['preferencia']['punto_referencia'] == preference['punto_referencia']
    for payload in [{'hora_preferida_inicio': '12:00'}, {'hora_preferida_inicio': '12:00', 'hora_preferida_fin': '12:00'},
                    {'hora_preferida_inicio': '25:00', 'hora_preferida_fin': '23:00'}, {'punto_referencia': 'x' * 501},
                    {'hora_preferida_inicio': '09:00+05:00', 'hora_preferida_fin': '10:00+05:00'}]:
        assert admin.put(f'/api/v1/clients/{cid}/preferences', json=payload).status_code == 422
    assert admin.put(f'/api/v1/clients/{cid}/preferences', json={}).json()['preferencia']['hora_preferida_inicio'] is None
    assert admin.put(f'/api/v1/clients/{cid}', json={'nombre': 'Cliente QA editado', 'estado': 'INACTIVO'}).status_code == 200
    assert admin.get('/api/v1/clients/', params={'q': 'Cliente QA editado'}).json()['total'] >= 1
    assert admin.get('/api/v1/clients/', params={'q': "' OR 1=1 --"}).json()['items'] == []
    assert admin.get('/api/v1/clients/?q=%25').json()['items'] == []
    assert admin.post('/api/v1/clients/', json={'nombre': ' '}).status_code == 422
    assert admin.put(f'/api/v1/clients/{uuid.uuid4()}/preferences', json={}).status_code == 404


def test_pdf_escapes_text_and_supports_pages():
    pdf = create_pdf(['Texto (QA) \\ operador'] * 110)
    assert b'/Count 3' in pdf and b'\\(QA\\)' in pdf and b'\\\\ operador' in pdf
    # Cross-reference offsets must identify the declared objects exactly.
    xref = pdf.split(b'xref\n', 1)[1].split(b'trailer', 1)[0].splitlines()[2:]
    for identifier, line in enumerate(xref, 1):
        assert pdf[int(line[:10]):].startswith(f'{identifier} 0 obj'.encode())


def test_manual_route_calculates_metrics_and_checks_full_windows(api_case):
    from unittest.mock import patch
    from app.services import routing
    admin, payload, driver, vehicle, _ = api_case
    data = {'code': 'Ok', 'routes': [{'geometry': {'type': 'LineString', 'coordinates': [[-75.21,-12.03],[-75.22,-12.04],[-75.22,-12.04]]},
            'distance': 2000, 'duration': 240, 'legs': [{'distance':1000,'duration':120},{'distance':1000,'duration':120}]}]}
    body = {'pedidos':payload['pedidos'], 'repartidor_id':driver['repartidor_id'], 'vehiculo_id':vehicle['vehiculo_id'], 'inicio_planificado':payload['inicio_planificado'], 'servicio_min_por_entrega':5}
    with patch.object(routing,'fetch_json',return_value=data):
        created = admin.post('/api/v1/routes/',json=body)
        assert created.status_code == 201, created.text
        route = created.json()
        assert float(route['co2_kg']) == 0.4 and float(route['combustible_l']) == 0.2
        assert all(delivery['eta'] for delivery in route['entregas'])
        path = '/api/v1/routes/'+route['ruta_id']+'/horario'
        rejected = admin.put(path,json={'inicio_planificado':'2030-01-02T16:25:00-05:00','servicio_min_por_entrega':5})
        assert rejected.status_code == 422, rejected.text
        unchanged = admin.get('/api/v1/routes/'+route['ruta_id']).json()
        assert unchanged['inicio_planificado'] == route['inicio_planificado']
        edited = admin.put(path,json={'inicio_planificado':'2030-01-02T09:10:00-05:00','servicio_min_por_entrega':4})
        assert edited.status_code == 200, edited.text
        assert edited.json()['entregas'][0]['eta'] != route['entregas'][0]['eta']


def test_manual_impossible_window_and_missing_legs_do_not_assign(api_case):
    from unittest.mock import patch
    from app.services import routing
    admin,payload,driver,vehicle,_ = api_case
    body = {'pedidos':payload['pedidos'], 'repartidor_id':driver['repartidor_id'], 'vehiculo_id':vehicle['vehiculo_id'], 'inicio_planificado':'2030-01-02T16:29:00-05:00'}
    data = {'code':'Ok','routes':[{'geometry':{'type':'LineString','coordinates':[[-75.21,-12.03],[-75.22,-12.04]]},'distance':2000,'duration':240,'legs':[{'distance':1000,'duration':120},{'distance':1000,'duration':120}]}]}
    with patch.object(routing,'fetch_json',return_value=data):
        assert admin.post('/api/v1/routes/',json=body).status_code == 422
    data['routes'][0]['legs'] = []
    with patch.object(routing,'fetch_json',return_value=data):
        assert admin.post('/api/v1/routes/',json={**body,'inicio_planificado':payload['inicio_planificado']}).status_code == 503
    orders=admin.get('/api/v1/orders/?estado=PENDIENTE&limit=1000').json()
    assert set(payload['pedidos']) <= {o['pedido_id'] for o in orders}


def test_planned_compliance_requires_whole_service_inside_window():
    from types import SimpleNamespace
    from datetime import datetime,timezone
    from app.services.sustainability import window_summary
    instant = datetime(2030,1,1,10,tzinfo=timezone.utc)
    order = SimpleNamespace(ventana_inicio=instant, ventana_fin=instant)
    detail = SimpleNamespace(eta=instant,estado_entrega='PENDIENTE')
    assert window_summary([(detail,order)],1)['cumplimiento_previsto_pct']==0
    assert window_summary([(detail,order)],None)['cumplimiento_previsto_pct'] is None
    assert b'CO2' in create_pdf(['CO₂'])


def test_order_reuses_registered_client_and_rejects_inactive_client(api_case):
    admin,payload,*_ = api_case
    client=admin.post('/api/v1/clients/',json={'nombre':'Cliente vinculado QA','estado':'INACTIVO'}).json()
    order=next(o for o in admin.get('/api/v1/orders/?limit=1000').json() if o['pedido_id']==payload['pedidos'][0])
    body={key:order[key] for key in ['direccion','latitud','longitud','peso_kg','ventana_inicio','ventana_fin','tipo_producto']}
    body['cliente_id']=client['cliente_id']
    assert admin.post('/api/v1/orders/',json=body).status_code==422
    assert admin.put('/api/v1/clients/'+client['cliente_id'],json={'nombre':client['nombre'],'estado':'ACTIVO'}).status_code==200
    saved=admin.post('/api/v1/orders/',json=body)
    assert saved.status_code==201, saved.text
    assert saved.json()['cliente_id']==client['cliente_id']
    assert saved.json()['cliente_nombre']=='Cliente vinculado QA'
