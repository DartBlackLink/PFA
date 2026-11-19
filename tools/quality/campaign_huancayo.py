"""Five predeclared seeds at 10/50/150 demands, real PostgreSQL and OSRM.

Only the exact QA database is accepted. Each case gets a new schema with the
same deterministic logical IDs and reference clock. No operational data touched.
Public OSRM requests are throttled to at most one start per second; that delay
is included in measured time. This is not a concurrent/production SLA test.
"""
from __future__ import annotations
from datetime import datetime, timedelta, time as clock, timezone
import hashlib
import argparse
import json
import os
from pathlib import Path
import platform
import secrets
import sys
from threading import Lock
from time import perf_counter, sleep
from uuid import UUID, NAMESPACE_URL, uuid5
from unittest.mock import patch

from sqlalchemy import create_engine, select, text
from sqlalchemy.engine import make_url
from sqlalchemy.schema import CreateSchema

SEEDS = (11, 22, 33, 44, 55)
SIZES = (10, 50, 150)
PLACES = [
    ('Plaza Constitución, Huancayo', -12.068046, -75.210073),
    ('Plaza Huamanmarca, Huancayo', -12.0708548, -75.2083245),
    ('Parque de la Identidad Huanca, Huancayo', -12.049215, -75.197825),
]


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--case',choices=[f'{size}:{seed}' for size in SIZES for seed in SEEDS])
    args=parser.parse_args()
    root=Path(os.environ.get('E2E_APP_ROOT',Path(__file__).resolve().parents[2]))
    output=Path(os.environ.get('CAMPAIGN_OUTPUT',root/'reports/campaign-huancayo'))
    url=make_url(os.environ['E2E_QA_DATABASE_URL'])
    if url.database!='ecologistica_revision_20261007' or url.host not in {'postgres-qa','127.0.0.1','localhost'} or os.environ.get('E2E_ALLOW_SCHEMA_CREATE')!='1':
        raise RuntimeError('Only the explicit QA database is accepted')
    output.mkdir(parents=True,exist_ok=False)
    os.environ.update(DATABASE_URL=url.render_as_string(hide_password=False),SECRET_KEY=secrets.token_hex(48),
        BOOTSTRAP_DEMO_USERS='false',ROUTING_BASE_URL='https://router.project-osrm.org/route/v1/driving',
        TRUSTED_HOSTS='testserver,localhost,127.0.0.1')
    sys.path.insert(0,str(root/'backend'))
    from alembic import command
    from alembic.config import Config
    from fastapi.testclient import TestClient
    from app.core.security import create_access_token,get_password_hash
    from app.db.session import SessionLocal
    from app.main import app
    from app.models.entities import Usuario,Repartidor,Vehiculo,Cliente,Pedido,Ruta,RutaDetalle
    from app.services import matrix
    from app.api.routes import optimization
    now=datetime.now(timezone.utc)
    run=secrets.token_hex(5)
    layout={'sizes':SIZES,'seeds':SEEDS,'places':PLACES,'clock':now.isoformat(),
            'origin':PLACES[0][1:],'weight_kg':1,'teams':15,'capacity_kg':20,
            'service_minutes':5,'window_minutes':150,'population':24,'generations':40}
    encoded=json.dumps(layout,sort_keys=True,ensure_ascii=False).encode()
    (output/'dataset.json').write_bytes(encoded)
    result={'date':now.isoformat(),'python':platform.python_version(),'platform':platform.platform(),
        'dataset_sha256':hashlib.sha256(encoded).hexdigest(),'cases':[],
        'scope':'ASGI endpoint, PostgreSQL, real OSRM and genetic solver plus confirmation; excludes TCP, browser/proxy/render',
        'limitation':'Three verified public destinations repeated as synthetic demand; no claim of representative city-wide or concurrent load.',
        'provider_throttle':'At most one public OSRM request start per second; waits included in timings',
        'no_operational_database':True,'selected_case':args.case,'provider_failures':[]}
    lock=Lock(); last=[0.0]; fetch=matrix.fetch_json
    def limited_fetch(*args,**kwargs):
        with lock:
            delay=max(0,1-(perf_counter()-last[0]))
            if delay:sleep(delay)
            last[0]=perf_counter()
        try:return fetch(*args,**kwargs)
        except Exception as error:
            result['provider_failures'].append({'kind':type(error).__name__,'message':str(error)[:250]})
            raise
    def save():
        (output/'campaign.json').write_text(json.dumps(result,ensure_ascii=False,indent=2),encoding='utf-8')
    for size in SIZES:
        for seed in SEEDS:
            if args.case and args.case!=f'{size}:{seed}':continue
            case={'orders':size,'teams':15,'seed':seed,'state':'STARTED'}
            result['cases'].append(case);save()
            schema=f'e2e_perf_{run}_{size}_{seed}'
            os.environ.pop('PGOPTIONS',None)
            owner=create_engine(url)
            with owner.begin() as c:c.execute(CreateSchema(schema))
            owner.dispose()
            os.environ['PGOPTIONS']='-c search_path='+schema
            config=Config(str(root/'backend/alembic.ini'))
            config.set_main_option('script_location',str(root/'backend/migrations'))
            command.upgrade(config,'head')
            engine=create_engine(url)
            SessionLocal.configure(bind=engine)
            try:
                def identifier(label):return uuid5(NAMESPACE_URL,f'ecologistica-performance-{size}-{label}')
                email='performance.admin@example.test'; emails={};teams=[];order_ids=[]
                password_hash=get_password_hash(secrets.token_hex(24))
                with SessionLocal() as db:
                    assert db.scalar(text('select current_schema()'))==schema
                    db.add(Usuario(usuario_id=identifier('admin'),email=email,password_hash=password_hash,rol='ADMIN',estado='ACTIVO'))
                    customer=Cliente(cliente_id=identifier('client'),nombre='QA PERF DEMANDA SINTETICA');db.add(customer)
                    for index in range(15):
                        user=Usuario(usuario_id=identifier(f'user-{index}'),email=f'performance.{index}@example.test',password_hash=password_hash,rol='REPARTIDOR',estado='ACTIVO')
                        db.add(user);db.flush()
                        vehicle=Vehiculo(vehiculo_id=identifier(f'vehicle-{index}'),placa=f'QAP-{index:03}',tipo='QA',capacidad_kg=20,consumo_km_l=10,factor_emision_kg_km=.2,anio_fabricacion=2025,estado='ACTIVO')
                        driver=Repartidor(repartidor_id=identifier(f'driver-{index}'),usuario_id=user.usuario_id,nombre=f'QA PERF {index}',dni=f'{80000000+index}',licencia='QA-PERF',categoria_licencia='A-IIb',disponible_desde=clock(0),disponible_hasta=clock(23,59),origen_latitud=PLACES[0][1],origen_longitud=PLACES[0][2],estado='ACTIVO')
                        db.add_all([vehicle,driver]);db.flush()
                        teams.append({'repartidor_id':str(driver.repartidor_id),'vehiculo_id':str(vehicle.vehiculo_id)})
                        emails[driver.repartidor_id]=user.email
                    for index in range(size):
                        place=PLACES[index%len(PLACES)]
                        order=Pedido(pedido_id=identifier(f'order-{index}'),cliente_id=customer.cliente_id,direccion=place[0],latitud=place[1],longitud=place[2],peso_kg=1,tipo_producto='QA',prioridad='ESTANDAR',ventana_inicio=now-timedelta(minutes=1),ventana_fin=now+timedelta(minutes=150),estado='PENDIENTE')
                        db.add(order);order_ids.append(str(order.pedido_id))
                    db.commit()
                with TestClient(app) as admin, patch.object(matrix,'fetch_json',side_effect=limited_fetch):
                    admin.headers['Authorization']='Bearer '+create_access_token(email,'ADMIN')
                    diagnosis={'shapes':[]}
                    case['diagnosis']=diagnosis
                    real_solve=optimization.solve
                    real_shape=optimization.road_shape
                    def measure_solve(*args,**kwargs):
                        before=perf_counter()
                        value=real_solve(*args,**kwargs)
                        diagnosis.update(solver_seconds=perf_counter()-before,solver_statistics=value[1],route_count=len(value[0].routes))
                        return value
                    def measure_shape(points,deadline):
                        before=perf_counter();record={'points':len(points),'unique_points':len(set(points))}
                        try:return real_shape(points,deadline)
                        except Exception as error:
                            record.update(error=type(error).__name__,cause=type(error.__cause__).__name__ if error.__cause__ else None)
                            raise
                        finally:
                            record['seconds']=perf_counter()-before
                            with lock:diagnosis['shapes'].append(record)
                    start=perf_counter()
                    with patch.object(optimization,'solve',side_effect=measure_solve),patch.object(optimization,'road_shape',side_effect=measure_shape):
                        preview=admin.post('/api/v1/optimizations/preview',json={'pedidos':order_ids,'equipos':teams,'inicio_planificado':now.isoformat(),'semilla':seed})
                    case.update(preview_seconds=perf_counter()-start,preview_status=preview.status_code)
                    if preview.status_code!=201:raise RuntimeError(f'Preview HTTP {preview.status_code}: {preview.json().get("detail")}')
                    plan=preview.json();case['statistics']=plan['estadisticas']
                    confirm_start=perf_counter()
                    confirmed=admin.post('/api/v1/optimizations/'+plan['plan_id']+'/confirm')
                    case.update(confirm_seconds=perf_counter()-confirm_start,total_seconds=perf_counter()-start,confirm_status=confirmed.status_code)
                    if confirmed.status_code!=200:raise RuntimeError('Confirmation failed')
                    route_ids=confirmed.json()['ruta_ids']; deliver=[]; routes=[]
                    for rid in route_ids:
                        r=admin.get('/api/v1/routes/'+rid).json();routes.append(r);deliver.extend(x['pedido_id'] for x in r['entregas'])
                    assert sorted(deliver)==sorted(order_ids) and len(set(deliver))==size
                    route=max(routes,key=lambda r:len(r['entregas']))
                    rid=route['ruta_id'];first=route['entregas'][0]
                    driver_email=emails[UUID(route['repartidor_id'])]
                    with TestClient(app) as driver:
                        driver.headers['Authorization']='Bearer '+create_access_token(driver_email,'REPARTIDOR')
                        assert driver.post('/api/v1/routes/'+rid+'/iniciar').status_code==200
                        done=driver.post('/api/v1/routes/'+rid+'/entregas/'+first['pedido_id']+'/confirmar?version=1')
                        assert done.status_code==200
                        first_time=done.json()['entregas'][0]['entregado_en']
                        event=str(uuid5(NAMESPACE_URL,f'{schema}-incident'))
                        point={'latitud':first['latitud'],'longitud':first['longitud']}
                        incident=driver.post('/api/v1/routes/'+rid+'/incidentes',json={'evento_id':event,'tipo':'CONGESTION','descripcion':'QA PERF: congestión simulada, no observación real.','demora_min':1,'afectacion':'BAJA',**point})
                        assert incident.status_code==200
                        before=perf_counter()
                        replan=admin.post('/api/v1/operations/routes/'+rid+'/replan',json={'evento_id':event,'version':1,'ubicacion_en':datetime.now(timezone.utc).isoformat(),'motivo':'QA PERF: reoptimización de pendientes tras incidencia simulada.',**point})
                        case.update(replan_seconds=perf_counter()-before,replan_status=replan.status_code,pending_on_replanned_route=len(route['entregas'])-1)
                        if replan.status_code!=201:raise RuntimeError(f'Replan HTTP {replan.status_code}: {replan.json().get("detail")}')
                        revision=replan.json()
                        approved=admin.post('/api/v1/operations/revisions/'+revision['revision_id']+'/confirm')
                        assert approved.status_code==200
                        assert driver.post('/api/v1/operations/routes/'+rid+'/ack',json={'version':2}).status_code==200
                        after=driver.get('/api/v1/routes/'+rid).json()
                        preserved=next(x for x in after['entregas'] if x['pedido_id']==first['pedido_id'])
                        assert preserved['entregado_en']==first_time and preserved['estado_entrega']=='ENTREGADO'
                        assert after['version_recibida']==after['version']==2
                    case.update(state='VERIFIED',unique_assigned=size,previous_delivery_preserved=True,
                        optimization_within_45s=case['total_seconds']<=45,replan_below_30s=case['replan_seconds']<30,
                        schema=schema)
            except Exception as error:
                case.update(state='FAILED',error=str(error))
            finally:
                engine.dispose();save()
            print(f"size={size} seed={seed} state={case['state']} total={case.get('total_seconds')} replan={case.get('replan_seconds')}",flush=True)
    result['completed']=datetime.now(timezone.utc).isoformat();save()
    failures=[c for c in result['cases'] if c['state']!='VERIFIED' or not c.get('optimization_within_45s') or not c.get('replan_below_30s')]
    print('Campaign cases:',len(result['cases']),'outside criteria:',len(failures))
    return bool(failures)


if __name__=='__main__':raise SystemExit(main())
