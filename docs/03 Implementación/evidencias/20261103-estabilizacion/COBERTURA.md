# Cobertura real del backend — 03/11/2026

127 pruebas aprobadas; Coverage.py con ramas activadas. Fuente: coverage.xml generado en esta ejecución.

**90,87591240875912408759124088 % combinada** = 2739 elementos cubiertos / 3014 medidos.
Líneas: 2261/2410; ramas: 478/604. Es backend/app y backend/migrations; no cobertura global de Flutter/Android ni porcentaje SonarQube.

HTML con código y líneas coloreadas (archivo local de auditoría: `index.html`) · [XML](coverage.xml) · [JUnit](test-results.xml)

## Comando ejecutado

```text
python -m pytest backend/tests --cov --cov-config=tools/quality/coverage.ini --cov-report=term-missing --cov-report=xml:reports/estabilizacion_20261103/coverage.xml --cov-report=html:reports/estabilizacion_20261103/htmlcov --junitxml=reports/estabilizacion_20261103/test-results.xml -q
```

Se ejecutó dentro de la imagen local de calidad y sobre PostgreSQL QA desechable, no la base principal.

La configuración conserva branch=True, source=backend/app,backend/migrations y fail_under=81. No se excluyeron módulos ni se alteraron pruebas para elevar el resultado.

## Módulos y líneas

| Archivo medido | Líneas cubiertas/medidas | Líneas sin ejecutar |
|---|---:|---|
| `__init__.py` | 0/0 | Ninguna |
| `env.py` | 20/24 | 19, 25–26, 42 |
| `main.py` | 38/43 | 24–25, 29–30, 38 |
| `optimization_schemas.py` | 43/46 | 35, 43, 45 |
| `schemas.py` | 207/215 | 48, 56, 98, 125, 178, 181, 189, 191 |
| `api/__init__.py` | 0/0 | Ninguna |
| `api/deps.py` | 30/31 | 38 |
| `api/router.py` | 17/17 | Ninguna |
| `api/routes/__init__.py` | 0/0 | Ninguna |
| `api/routes/auth.py` | 54/56 | 65–66 |
| `api/routes/drivers.py` | 62/79 | 30, 40, 57, 59–62, 65, 68, 81, 89–91, 100–102, 120 |
| `api/routes/geocoding.py` | 61/69 | 47, 55, 65, 81, 93, 97, 109, 134 |
| `api/routes/health.py` | 5/5 | Ninguna |
| `api/routes/operations.py` | 251/279 | 138, 146, 185–190, 197, 210, 215, 218, 220, 222, 226, 228, 270, 304, 308, 324, 345, 353, 374, 376, 410, 419, 424–425 |
| `api/routes/optimization.py` | 143/148 | 93, 198–199, 358, 360 |
| `api/routes/orders.py` | 30/30 | Ninguna |
| `api/routes/routes.py` | 218/241 | 80, 153, 172, 176, 179, 242–244, 252, 303–305, 327, 335, 337, 345, 353, 364, 413, 431, 440, 442, 447 |
| `api/routes/vehicles.py` | 33/38 | 21, 40–42, 58 |
| `core/__init__.py` | 0/0 | Ninguna |
| `core/config.py` | 60/60 | Ninguna |
| `core/request_limits.py` | 38/39 | 54 |
| `core/security.py` | 22/22 | Ninguna |
| `db/__init__.py` | 0/0 | Ninguna |
| `db/session.py` | 16/16 | Ninguna |
| `models/__init__.py` | 2/2 | Ninguna |
| `models/entities.py` | 187/187 | Ninguna |
| `services/__init__.py` | 0/0 | Ninguna |
| `services/genetic.py` | 231/249 | 117, 136, 139, 172, 179, 181, 183, 194, 200, 209, 211–214, 232, 361, 373, 377 |
| `services/matrix.py` | 93/103 | 47, 58, 103–104, 129, 135, 142, 151, 164, 168 |
| `services/operation_area.py` | 16/16 | Ninguna |
| `services/optimization_context.py` | 76/84 | 26, 36, 78, 80, 84, 119, 128, 149 |
| `services/provider_http.py` | 13/13 | Ninguna |
| `services/routing.py` | 25/25 | Ninguna |
| `services/scheduling.py` | 31/31 | Ninguna |
| `services/traffic.py` | 79/82 | 47, 71–72 |
| `services/traffic_references.py` | 1/1 | Ninguna |
| `versions/0001_initial_schema.py` | 33/33 | Ninguna |
| `versions/0002_access_and_resources.py` | 20/20 | Ninguna |
| `versions/0003_route_geometry.py` | 15/15 | Ninguna |
| `versions/0004_route_schedule.py` | 19/19 | Ninguna |
| `versions/0005_optimization_plan.py` | 17/17 | Ninguna |
| `versions/0006_route_operation.py` | 24/24 | Ninguna |
| `versions/0007_traffic_replanning.py` | 31/31 | Ninguna |

El HTML identifica las líneas ejecutadas/no ejecutadas y las ramas parciales. Cubrir una línea no demuestra que estén cubiertas todas sus combinaciones de entrada.

Flutter se verificó mediante 81 pruebas y un caso nativo compuesto de continuación; no se generó una medición nueva de cobertura Dart.
