# Resultados reales de desarrollo y validación web

**Proyecto:** EcoLogística Huancayo. **Responsable:** Jordy Steve Chancasanampa Torres. **Corte técnico:** 14/11/2026, America/Lima.

## Versión y entorno

Desarrollo: D:/UC/App/ecologistica. Entrega: C:/Users/jordy/PFA (copia selectiva y verificada). Base Git anterior: 7bad34b; esta intervención no hace commit/push. Python QA 3.14, API Docker Python 3.12; Flutter/Dart existentes. QA usa esquema aislado en la base de pruebas existente; la web opera con FastAPI y PostgreSQL activos. El hash servido final está en deployment-final.json.

## Pruebas ejecutadas

| Control | Resultado | Evidencia |
|---|---|---|
| Backend completo | **141 aprobadas**; 889 advertencias de dependencias/deprecación, no 141 fallos. | [Log](backend-full.log), [JUnit](test-results.xml) |
| Cobertura backend | **90.0313479624 % (2872/3190, líneas + ramas); líneas 2321/2492, ramas 551/698**. Mínimo configurado 81% conservado. | [XML](coverage.xml), [HTML](htmlcov/index.html) |
| Flutter completo | **93 aprobadas** (86 previas + 7 nuevas), ejecutadas en serie. | [Log](flutter-full-final.log) |
| Análisis Flutter | Sin incidencias en la raíz real del proyecto. | [Log](flutter-analyze-final.log) |
| Web release | Candidata final compilada y hash del JavaScript servido contrastado. | [Compilación](build-web-final.log), [despliegue](deployment-final.json) |
| Bandit | Resultado del análisis final en JSON; sin hallazgos según el archivo. No demuestra ausencia universal de vulnerabilidades. | [JSON](bandit.json) |
| Dependencias | Hallazgo CVE-2026-126360 en el lock 1.45.1; actualización a 1.45.2 y auditoría repetida. No se demostró explotación en la app. | [Antes](dependency-audit-before.json), [Después](dependency-audit.json) |
| Permisos/runtime | ADMIN y ambos repartidores; anónimo 401, rol 403, recurso ajeno 404, datos persistidos. | [Peticiones](runtime-api.jsonl), [flujo](flujo-web-final.json) |
| PDF | Descarga por botón; pypdf y render Poppler revisados. No es una pantalla informativa. | [PDF con indicadores](reporte-ruta-verificado.pdf), [render](capturas/pdf-descargado.png) |
| UI real | 360 px, claro/oscuro, campos, acciones, errores y navegación; no auditoría WCAG integral. | [Modal](capturas/modal-ambiental-360.png), [clientes](capturas/cliente-inactivo-360-oscuro.png) |
| SonarQube | **No ejecutado nuevo**: no credencial privada vigente. No adjudicar a esta versión el análisis histórico. | Documento de acciones externas |

## Comandos y límites

```powershell
# Backend: runner prepara DATABASE_URL privada de QA y PGOPTIONS con esquema aislado.
python desarrollo_integral_20261114/probar_backend.py --full
# Comando interno: backend/.venv/Scripts/python.exe -m pytest backend/tests -p no:cacheprovider --cov=backend/app --cov-config=.coveragerc --cov-report=xml:... --cov-report=html:... --junitxml=... -q
# En la raíz de la aplicación:
flutter test --concurrency=1 --reporter expanded
flutter analyze
flutter build web --release --output build/web-candidate-final-20261114 --dart-define=API_BASE_URL=http://127.0.0.1:8000/api/v1
bandit -q -r backend/app -f json -o resultado.json
python -m pip_audit --disable-pip --no-deps -r backend/requirements.lock.txt --format=json -o auditoria.json
```

El runner local y las credenciales no se publican. Para reproducir en otra máquina, provisionar una base QA separada y las variables privadas; `backend/tests/conftest.py` rechaza la base de la aplicación. El lock enumera los paquetes auditados sin instalar contra Python global. Ruff no está instalado en el entorno de pruebas y no se presenta como control aprobado.

Una ejecución focalizada inicial pasó 6 tests pero no alcanzó la cobertura global al no ejecutar la suite completa. Se conservó el umbral 81% y se cerró con la regresión completa. Los primeros tests de widgets requirieron corregir el desplazamiento del propio test y liberar sus temporizadores; no se redujeron las validaciones del producto. Un análisis accidental desde la carpeta de auxiliares no se atribuye a la aplicación: el resultado válido es el de su raíz.

## Rendimiento medido

**Optimización:** 16.649721700 s, HTTP 201, 150 pedidos/15 equipos, 150 asignados, semilla 42, 25 llamadas de matriz OSRM y geometrías viales reales. Demanda QA repetida en 3 puntos públicos de Huancayo; no 150 direcciones distintas. **Reoptimización:** 1.780739300 s, HTTP 201, 3 pedidos pendientes y demora QA de 1 min. Ambos bajo 45/30 s en estos casos.

La medición incluye endpoint por TestClient, SQL, OSRM y motor; excluye transporte del proxy, navegador y renderizado. El primer instrumento esperaba 200 y recibió 201, correcto del contrato: se conservó la respuesta original, se corrigió la expectativa y se mantuvo el tiempo original, sin repetir la muestra favorable. [Resultado](benchmark-integrado.json). No es campaña de 5 semillas, 150 destinos distintos, peor caso, SLA poblacional ni tráfico en vivo.

## Flujo por botones y datos conservados

Se agregó un cliente QA y tres pedidos QA en ubicaciones públicas ya existentes: dos se prepararon por API para el ciclo operativo y el tercero se registró por el formulario web, conservando cliente_id, referencia, carga y coordenadas. ADMIN generó/confirmó una ruta; REPARTIDOR recibió, inició y confirmó la primera entrega; reportó congestión simulada; ADMIN calculó/comparó/aprobó; REPARTIDOR acusó la versión 2 y confirmó la segunda entrega; ADMIN resolvió la incidencia. Se verificó FINALIZADA, versión 2 recibida, primera hora conservada, dos entregas y aislamiento. La alternativa no mejoró: sin diferencia, sin ahorro acreditado. Los 21 pedidos, 20 vehículos y 10 conductores anteriores se conservan; los datos QA no se presentan como operaciones comerciales.

Respaldo privado y huellas se guardan fuera del repositorio. Se verificó la conexión activa ecologistica_operativa antes de migrar; POSTGRES_DB correspondía a una base heredada. La migración 0008 es aditiva; no se borró historial. [Control de integridad](integridad-final.json).

## Interpretación ambiental

Indicadores de la última versión: tras reoptimizar, representan el tramo pendiente recalculado, no un acumulado físico completo. Combustible y CO₂ son estimados. La equivalencia EPA de 8.887 kg CO₂/galón US es una referencia de combustión, no un factor local medido ni compensación real; fuente [EPA](https://www.epa.gov/energy/greenhouse-gas-equivalencies-calculator-calculations-and-references). Sin parámetro o dato, el indicador permanece no disponible.

[Matriz del backlog](../../MATRIZ_FINAL_BACKLOG_WEB.md) · [Acciones externas](../../ACCIONES_EXTERNAS_Y_CIERRE_WEB.md)
