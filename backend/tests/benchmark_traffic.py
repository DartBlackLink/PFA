"""Reproducible CPU benchmark, explicitly NOT full provider/API latency.

Run from /workspace with PYTHONPATH=backend python backend/tests/benchmark_traffic.py.
Matrix is synthetic/directed and tagged in every record. Does not write a DB.
"""
import json
import platform
from datetime import datetime, timezone
from time import perf_counter

from app.services.genetic import Delivery, Parameters, Rules, Team, solve
from app.services.traffic import TrafficDurations

points=[(-12.04+(i%15)*0.0001,-75.23+(i//15)*0.0001) for i in range(165)]
distance=[[0.0 if i==j else 0.2+abs(i-j)*0.002 for j in range(165)] for i in range(165)]
base=[[v*2 for v in row] for row in distance]
deliveries=[Delivery(str(i),15+i,1,0,600) for i in range(150)]
teams=[Team(str(i),i,15,10,0.2,0,600) for i in range(15)]
rule={'nombre':'Aproximación QA','sur':-12.05,'norte':-12.03,'oeste':-75.24,'este':-75.22,
    'dias':list(range(7)),'inicio_min':420,'fin_min':600,'factor':1.5,'fundamento':'Regla sintética del benchmark; no tráfico observado'}
records=[]
for name,items,equipment,coordinates,dist,times,limit,target in [
    ('optimization_150_15',deliveries,teams,points,distance,TrafficDurations(base,points,datetime(2026,11,3,12,tzinfo=timezone.utc),{'reglas':[rule]}),8,45),
    ('reoptimization_149_15',deliveries[1:],teams,points,distance,TrafficDurations(base,points,datetime(2026,11,3,12,tzinfo=timezone.utc),{'reglas':[rule]},delay=10),5,30),
]:
    clock=perf_counter()
    try:
        plan,stats=solve(items,equipment,dist,times,Rules(return_to_origin=True),Parameters(seconds=limit))
        elapsed=perf_counter()-clock
        records.append({'case':name,'seconds':elapsed,'target_seconds':target,'below_target':elapsed<target,
            'orders':len(items),'vehicles':len(equipment),'assigned':sum(len(r.deliveries) for r in plan.routes),
            'stats':stats,'input':'SYNTHETIC_MATRIX_AND_MANUAL_PROFILE','scope':'CPU_SOLVER_ONLY_NOT_END_TO_END'})
    except Exception as error:
        records.append({'case':name,'seconds':perf_counter()-clock,'error':type(error).__name__,'scope':'CPU_SOLVER_ONLY_NOT_END_TO_END'})
print(json.dumps({'hardware':platform.uname()._asdict(),'python':platform.python_version(),'records':records},indent=2))
