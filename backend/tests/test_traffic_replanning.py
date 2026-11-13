"""PostgreSQL/API acceptance; controlled roads are explicitly test fixtures."""
from concurrent.futures import ThreadPoolExecutor
from datetime import datetime, timedelta, timezone
from unittest.mock import patch
import uuid

from fastapi.testclient import TestClient
from sqlalchemy import select

from app.api.routes import operations
from app.db.session import SessionLocal
from app.main import app
from app.models.entities import Incidente, Pedido, RevisionRuta, Ruta, RutaDetalle
from app.services.traffic import TrafficDurations
from test_optimization_api import api_case, matrix, roads
from test_route_operation import setup_route


INSTANT = datetime(2030, 1, 2, 14, 15, tzinfo=timezone.utc)


def running(case):
    admin, courier, identifier = setup_route(case)
    assert courier.post(f'/api/v1/routes/{identifier}/iniciar').status_code == 200
    with SessionLocal() as db:
        route = db.get(Ruta, uuid.UUID(identifier))
        route.iniciado_en = INSTANT - timedelta(minutes=15)
        db.commit()
    return admin, courier, identifier


def report(courier, identifier, **extra):
    body = {'evento_id': str(uuid.uuid4()), 'tipo': 'CONGESTION',
        'descripcion': 'Congestión de prueba controlada, no es dato real.',
        'latitud': -12.04, 'longitud': -75.22, 'demora_min': 5, 'afectacion': 'MEDIA', **extra}
    response = courier.post(f'/api/v1/routes/{identifier}/incidentes', json=body)
    assert response.status_code == 200, response.text
    return body


def request_revision(admin, identifier, event, **extra):
    body = {'evento_id': event['evento_id'], 'version': 1,
        'latitud': -12.04, 'longitud': -75.22, 'ubicacion_en': INSTANT.isoformat(),
        'motivo': 'Reordenar pendientes tras congestión reportada.', **extra}
    with patch.object(operations, 'now', return_value=INSTANT), \
         patch.object(operations, 'road_matrix', side_effect=matrix), \
         patch.object(operations, 'road_shape', side_effect=roads):
        return admin.post(f'/api/v1/operations/routes/{identifier}/replan', json=body)


def confirm(admin, revision):
    with patch.object(operations, 'now', return_value=INSTANT + timedelta(seconds=15)):
        return admin.post(f"/api/v1/operations/revisions/{revision['revision_id']}/confirm")


def test_gold_versions_keep_completed_deliveries_and_require_receipt(api_case):
    admin, courier, identifier = running(api_case)
    base = '/api/v1/routes/' + identifier
    first = courier.get(base).json()['entregas'][0]['pedido_id']
    done = courier.post(base + f'/entregas/{first}/confirmar').json()['entregas'][0]
    event = report(courier, identifier)
    inbox = admin.get('/api/v1/operations/notifications').json()
    assert any(n['tipo'] == 'INCIDENCIA' and n['referencia_id'] == event['evento_id'] for n in inbox)
    response = request_revision(admin, identifier, event)
    assert response.status_code == 201, response.text
    revision = response.json()
    assert len(revision['propuesta']['entregas']) == 1
    assert courier.get(base).json()['version'] == 1
    assert confirm(admin, revision).status_code == 200
    assert confirm(admin, revision).status_code == 200
    updated = courier.get(base).json()
    assert updated['version'] == 2 and updated['version_recibida'] == 1
    preserved = next(d for d in updated['entregas'] if d['pedido_id'] == first)
    assert preserved == done
    pending = next(d for d in updated['entregas'] if d['pedido_id'] != first)['pedido_id']
    assert courier.post(base + f'/entregas/{pending}/confirmar?version=1').status_code == 409
    assert courier.post('/api/v1/operations/routes/'+identifier+'/ack', json={'version':1}).status_code == 409
    ack = '/api/v1/operations/routes/'+identifier+'/ack'
    assert courier.post(ack, json={'version':2}).status_code == 200
    assert courier.post(ack, json={'version':2}).status_code == 200
    assert courier.post(base+f'/entregas/{pending}/confirmar?version=2').status_code == 200
    with SessionLocal() as db:
        item = db.get(RevisionRuta, uuid.UUID(revision['revision_id']))
        assert item.aprobado_por and item.recibido_en
        assert item.anterior['ruta']['version'] == 1
        assert len(list(db.scalars(select(RutaDetalle).where(RutaDetalle.ruta_id == uuid.UUID(identifier))))) == 2


def test_incident_idempotency_notification_and_payload_validation(api_case):
    admin, courier, identifier = running(api_case)
    event = report(courier, identifier, latitud=-12.040000123)
    base = '/api/v1/routes/'+identifier+'/incidentes'
    assert courier.post(base, json=event).status_code == 200
    assert courier.post(base, json={**event, 'demora_min': 20}).status_code == 409
    inbox = admin.get('/api/v1/operations/notifications').json()
    rows = [n for n in inbox if n['referencia_id'] == event['evento_id']]
    assert len(rows) == 1
    assert admin.post('/api/v1/operations/notifications/'+rows[0]['id']+'/read').status_code == 200
    assert courier.post('/api/v1/operations/notifications/'+rows[0]['id']+'/read').status_code == 404
    for invalid in [{'latitud': 91}, {'longitud': None}, {'demora_min':-1}, {'demora_min':241}, {'afectacion':'EXTREMA'}, {'ocurrido_en':'2030-01-02T10:00:00'}]:
        assert courier.post(base,json={**event,'evento_id':str(uuid.uuid4()),**invalid}).status_code == 422
    assert admin.post(base,json=event).status_code == 403


def test_inadequate_location_and_road_closure_leave_route_untouched(api_case):
    admin, courier, identifier = running(api_case)
    event = report(courier, identifier)
    original = admin.get('/api/v1/routes/'+identifier).json()
    assert request_revision(admin, identifier, event, ubicacion_en=(INSTANT-timedelta(minutes=6)).isoformat()).status_code == 422
    assert request_revision(admin, identifier, event, latitud=100).status_code == 422
    closure = report(courier, identifier, tipo='VIA_CERRADA')
    denied = request_revision(admin, identifier, closure)
    assert denied.status_code == 422 and 'excluir' in denied.text
    assert admin.get('/api/v1/routes/'+identifier).json() == original


def test_completed_during_calculation_invalidates_proposal(api_case):
    admin, courier, identifier = running(api_case)
    event = report(courier, identifier)
    response = request_revision(admin, identifier, event)
    assert response.status_code == 201, response.text
    first = courier.get('/api/v1/routes/'+identifier).json()['entregas'][0]['pedido_id']
    assert courier.post(f'/api/v1/routes/{identifier}/entregas/{first}/confirmar').status_code == 200
    assert confirm(admin,response.json()).status_code == 409
    assert courier.get('/api/v1/routes/'+identifier).json()['version'] == 1


def test_two_concurrent_confirmations_activate_only_one_version(api_case):
    admin, courier, identifier = running(api_case)
    event = report(courier, identifier)
    one = request_revision(admin, identifier, event).json()
    two = request_revision(admin, identifier, event).json()
    with patch.object(operations,'now',return_value=INSTANT+timedelta(seconds=10)):
        def send(item):
            with TestClient(app) as other:
                other.headers['Authorization'] = admin.headers['Authorization']
                return other.post('/api/v1/operations/revisions/'+item['revision_id']+'/confirm').status_code
        with ThreadPoolExecutor(max_workers=2) as pool:
            statuses = list(pool.map(send,[one,two]))
    assert sorted(statuses) == [200,409]
    route = courier.get('/api/v1/routes/'+identifier).json()
    assert route['version'] == 2 and route['version_recibida'] == 1


def test_changed_traffic_invalidates_proposal_and_policy_is_admin_only(api_case):
    admin,courier,identifier = running(api_case)
    event=report(courier,identifier)
    item=request_revision(admin,identifier,event).json()
    policy=admin.get('/api/v1/operations/traffic').json()
    assert courier.put('/api/v1/operations/traffic',json={'revision':policy['revision'],'reglas':[]}).status_code==403
    assert admin.put('/api/v1/operations/traffic',json={'revision':policy['revision'],'reglas':[]}).status_code==200
    assert admin.put('/api/v1/operations/traffic',json={'revision':policy['revision'],'reglas':[]}).status_code==409
    assert confirm(admin,item).status_code==409


def test_provider_outage_or_impossible_window_preserves_current_route(api_case):
    admin,courier,identifier=running(api_case)
    event=report(courier,identifier)
    from fastapi import HTTPException
    with patch.object(operations,'road_matrix',side_effect=HTTPException(503,'Proveedor no disponible')):
        response=request_revision_outage(admin,identifier,event)
        assert response.status_code==503
    with SessionLocal() as db:
        route=db.get(Ruta,uuid.UUID(identifier))
        detail=db.scalar(select(RutaDetalle).where(RutaDetalle.ruta_id==route.ruta_id))
        order=db.get(Pedido,detail.pedido_id)
        order.ventana_fin=INSTANT-timedelta(minutes=1)
        order.ventana_inicio=INSTANT-timedelta(hours=1)
        db.commit()
    assert request_revision(admin,identifier,event).status_code==422
    assert courier.get('/api/v1/routes/'+identifier).json()['version']==1


def request_revision_outage(admin,identifier,event):
    with patch.object(operations,'now',return_value=INSTANT):
        return admin.post(f'/api/v1/operations/routes/{identifier}/replan',json={
            'evento_id':event['evento_id'],'version':1,'latitud':-12.04,'longitud':-75.22,
            'ubicacion_en':INSTANT.isoformat(),'motivo':'Prueba de indisponibilidad vial'})


def test_rejection_resolution_and_permission_boundaries(api_case):
    admin,courier,identifier=running(api_case)
    event=report(courier,identifier)
    item=request_revision(admin,identifier,event).json()
    path='/api/v1/operations/revisions/'+item['revision_id']
    assert courier.post(path+'/confirm').status_code==403
    assert courier.post('/api/v1/operations/routes/'+str(uuid.uuid4())+'/ack',json={'version':1}).status_code==404
    assert admin.post(path+'/reject').json()['estado']=='RECHAZADA'
    assert confirm(admin,item).status_code==409
    resolve='/api/v1/operations/incidents/'+event['evento_id']+'/resolve'
    assert admin.post(resolve,json={'resolucion':' ' * 12}).status_code==422
    assert courier.post(resolve,json={'resolucion':'Gestionado por conductor'}).status_code==403
    assert admin.post(resolve,json={'resolucion':'Verificado por coordinación, reporte conservado'}).status_code==200
    with SessionLocal() as db:
        assert db.get(Incidente,uuid.UUID(event['evento_id'])).resuelto_en


def test_time_dependent_zonal_estimate_varies_by_location_and_departure():
    rule={'nombre':'Zona QA','sur':-12.05,'norte':-12.03,'oeste':-75.23,'este':-75.21,
        'dias':[2],'inicio_min':540,'fin_min':600,'factor':2,'fundamento':'Supuesto controlado de prueba'}
    points=[(-12.04,-75.22),(-12.0,-75.20),(-13,-78)]
    base=[[0,10,10],[10,0,10],[10,10,0]]
    duration=TrafficDurations(base,points,INSTANT,{'reglas':[rule]})
    assert duration.minutes(0,1,0)==20
    assert duration.minutes(1,2,0)==10
    assert duration.minutes(0,1,45)==10
    arrivals=[minute+duration.minutes(0,1,minute) for minute in range(36,47)]
    assert arrivals==sorted(arrivals), 'FIFO must hold across the end of peak hours'


def test_policy_validations_and_applied_profile_in_generation(api_case):
    admin,payload,*_=api_case
    rule={'nombre':'Zona QA','sur':-12.05,'norte':-12.01,'oeste':-75.24,'este':-75.20,
        'dias':[2],'inicio_min':480,'fin_min':1020,'factor':2,'fundamento':'Escenario sintético controlado para verificar el uso del horario'}
    policy=admin.get('/api/v1/operations/traffic').json()
    for invalid in [{'norte':-12.06},{'dias':[7]},{'dias':[2,2]},{'fin_min':400},{'factor':0.5},{'nombre':'   '},{'fundamento':' '*15}]:
        result=admin.put('/api/v1/operations/traffic',json={'revision':policy['revision'],'reglas':[{**rule,**invalid}]})
        assert result.status_code==422, result.text
    assert admin.put('/api/v1/operations/traffic',json={'revision':policy['revision'],'reglas':[rule]}).status_code==200
    plan=admin.post('/api/v1/optimizations/preview',json=payload)
    assert plan.status_code==201,plan.text
    data=plan.json()
    assert data['estadisticas']['trafico']['trafico_en_vivo'] is False
    assert data['rutas'][0]['travel']==12, 'Three road legs of two base minutes at factor two'
    # Return to empty profile so independent fixtures do not inherit this test scenario.
    policy=admin.get('/api/v1/operations/traffic').json()
    assert admin.put('/api/v1/operations/traffic',json={'revision':policy['revision'],'reglas':[]}).status_code==200
