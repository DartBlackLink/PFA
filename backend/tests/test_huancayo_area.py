"""Huancayo boundary acceptance, including historic Lima data kept unchanged."""
import uuid
from unittest.mock import patch
import pytest
from fastapi import HTTPException

from app.api.routes import geocoding
from app.db.session import SessionLocal
from app.models.entities import Pedido, Ruta
from app.services.operation_area import contains, metadata
from app.services.traffic import TrafficRule
from test_optimization_api import api_case
from test_route_operation import setup_route


@pytest.mark.parametrize('point',[(-12.0675,-75.2103),(-12.05,-75.21),(-12.09,-75.21),
    (-12.047,-75.25),(-11.99,-75.235),(-12.10,-75.22),(-12.14,-75.23),(-12.141,-75.147)])
def test_approved_urban_surroundings_are_accepted(point):
    assert contains(*point)
    assert metadata()['zona_horaria']=='America/Lima'


@pytest.mark.parametrize('point',[(-12.0519,-77.0346),(0,0),(None,None),(float('nan'),-75.2)])
def test_lima_and_invalid_points_are_outside(point):
    assert not contains(*point)


def test_geocoding_filters_lima_even_if_provider_ignores_bbox():
    geocoding._cache.clear();geocoding._next_request=0
    feature={'properties':{'countrycode':'PE','name':'Lugar fuera de Huancayo','city':'Lima'},
        'geometry':{'type':'Point','coordinates':[-77.0346,-12.0519]}}
    with patch.object(geocoding,'fetch_json',return_value={'features':[feature]}) as fetch:
        assert geocoding.search('Parque')==[]
        assert 'bbox=-75.32%2C-12.18%2C-75.12%2C-11.94' in fetch.call_args.args[0]
    with patch.object(geocoding,'fetch_json') as fetch:
        with pytest.raises(HTTPException) as rejected:geocoding.reverse(-12.0519,-77.0346)
        assert rejected.value.status_code==422
        fetch.assert_not_called()


def test_api_rejects_order_origin_incident_and_replan_outside_huancayo(api_case):
    admin,payload,driver,vehicle,password=api_case
    order={'cliente_nombre':'QA fuera de zona','direccion':'Destino de prueba en Lima',
        'latitud':-12.0519,'longitud':-77.0346,'peso_kg':1,'tipo_producto':'GENERAL',
        'ventana_inicio':'2030-01-02T09:00:00-05:00','ventana_fin':'2030-01-02T16:30:00-05:00'}
    assert admin.post('/api/v1/orders/',json=order).status_code==422
    changed={k:v for k,v in driver.items() if k in ['nombre','dni','licencia','categoria_licencia','anios_experiencia','contacto','disponible_desde','disponible_hasta','correo']}
    changed.update(dni='99887766',correo='outside.'+uuid.uuid4().hex+'@example.test',password=password,
        origen_latitud=-12.0519,origen_longitud=-77.0346)
    assert admin.post('/api/v1/drivers/',json=changed).status_code==422
    admin,courier,identifier=setup_route(api_case)
    assert courier.post('/api/v1/routes/'+identifier+'/iniciar').status_code==200
    event={'evento_id':str(uuid.uuid4()),'tipo':'CONGESTION','descripcion':'Ubicación ajena de prueba, rechazar',
        'latitud':-12.0519,'longitud':-77.0346,'demora_min':5}
    assert courier.post('/api/v1/routes/'+identifier+'/incidentes',json=event).status_code==422
    body={k:event[k] for k in ['evento_id','latitud','longitud']}
    body.update(version=1,motivo='Posición fuera del ámbito operativo',ubicacion_en='2030-01-02T09:00:00-05:00')
    assert admin.post('/api/v1/operations/routes/'+identifier+'/replan',json=body).status_code==422


def test_legacy_outside_data_is_read_only_and_not_relocated(api_case):
    admin,courier,identifier=setup_route(api_case)
    with SessionLocal() as db:
        route=db.get(Ruta,uuid.UUID(identifier))
        route.origen_latitud=-12.0519;route.origen_longitud=-77.0346
        db.commit()
    view=courier.get('/api/v1/routes/'+identifier)
    assert view.status_code==200 and view.json()['fuera_zona'] is True
    assert courier.post('/api/v1/routes/'+identifier+'/iniciar').status_code==409
    assert admin.put('/api/v1/routes/'+identifier+'/horario',json={
        'inicio_planificado':'2030-01-02T09:00:00-05:00',
        'servicio_min_por_entrega':1}).status_code==409
    with SessionLocal() as db:
        assert float(db.get(Ruta,uuid.UUID(identifier)).origen_longitud)==-77.0346


def test_preexisting_order_outside_area_cannot_enter_optimizer(api_case):
    admin,payload,*_=api_case
    with SessionLocal() as db:
        order=db.get(Pedido,uuid.UUID(payload['pedidos'][0]))
        order.longitud=-77.0346;db.commit()
    assert admin.post('/api/v1/optimizations/preview',json=payload).status_code==422


def test_traffic_profile_from_lima_is_rejected():
    with pytest.raises(ValueError):TrafficRule(nombre='Perfil de otra ciudad',sur=-12.06,norte=-12.04,
        oeste=-77.05,este=-77.02,dias=[0],inicio_min=480,fin_min=540,factor=1.2,
        fundamento='Supuesto negativo para rechazar otra ciudad')


def test_local_references_do_not_invent_delay_factor(api_case):
    admin,*_=api_case
    response=admin.get('/api/v1/operations/traffic/references')
    assert response.status_code==200
    reference=response.json()[0]
    assert reference['inicio_min']==480 and reference['fin_min']==540
    assert reference['estudio_anio']==2015 and reference['factor_sugerido'] is None
    assert '12894/1182' in reference['fuente']
