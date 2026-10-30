"""Reproducible synthetic CPU benchmark, not a traffic/network benchmark."""
import json
import math
from pathlib import Path
import platform
import sys
from time import perf_counter

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'backend'))
from app.services.genetic import Delivery, Team, Rules, Parameters, evaluate_route, solve

coordinates = [(0., 0.)] + [(i % 15 / 10, i // 15 / 10) for i in range(150)]
distance = [[math.dist(a, b) for b in coordinates] for a in coordinates]
duration = [[value * 2 for value in row] for row in distance]
deliveries = [Delivery(str(i), i + 1, 1, 0, 480) for i in range(150)]
teams = [Team(str(i), 0, 10, 10, .2, 0, 480) for i in range(15)]
rules, parameters = Rules(), Parameters()
started = perf_counter()
plan, stats = solve(deliveries, teams, distance, duration, rules, parameters)
wall_ms = (perf_counter() - started) * 1000
assert not plan.unassigned
assert sorted(d for r in plan.routes for d in r.deliveries) == sorted(d.identifier for d in deliveries)
by_id = {d.identifier: d for d in deliveries}
by_team = {t.identifier: t for t in teams}
for route in plan.routes:
    assert route == evaluate_route(by_team[route.team], [by_id[d] for d in route.deliveries], distance, duration, rules)
result = {'python': platform.python_version(), 'platform': platform.platform(),
    'dataset': '150 synthetic orders, 15 vehicles, Euclidean km and 30 km/h, 8h windows',
    'wall_ms': round(wall_ms, 2), 'routes': len(plan.routes), 'validated_deliveries': 150,
    'stats': stats, 'scope': 'solver only; excludes database, provider, network, rendering',
    'parameters': parameters.__dict__}
(ROOT / 'reports').mkdir(exist_ok=True)
(ROOT / 'reports/genetic-benchmark.json').write_text(json.dumps(result, indent=2), encoding='utf-8')
print(json.dumps(result, indent=2))
