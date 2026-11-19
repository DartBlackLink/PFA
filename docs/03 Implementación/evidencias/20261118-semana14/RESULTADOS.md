# Implementación complementaria y verificación — 18/11/2026

**Proyecto:** EcoLogística Huancayo. **Responsable:** Jordy Steve Chancasanampa Torres. **Zona:** America/Lima. **Publicación:** no realizada.

## Qué se implementó y corrigió

1. Matriz vial deduplicada por coordenadas exactas, conservando dimensiones, índices y direccionalidad. Caso frío 150/11: antes fallaba, después 23,330 s hasta confirmación; el motor no se reemplazó por distancias inventadas.
2. Compatibilidad OSRM 1×1: una coordenada devuelve 400 InvalidOptions; repetir el mismo punto con selección 0/0 devuelve 200. Se preserva el chequeo vial y los datos de la entrega. Cuatro regresiones nuevas cubren duplicados, caché, puntos cercanos distintos y el contrato monopunto.
3. Suite Playwright reproducible y tres navegadores; frontend/backend reales contra PostgreSQL QA. Se separaron puertos 8010/8095 del stub8090 y se corrigió la instrumentación de texto/semántica WebKit, desplazamiento y aislamiento de credenciales inválidas por navegador. Ningún error de instrumento se atribuye a pérdida de datos operativos.
4. Instrumento SUS anónimo, CSV, unificador y calculador con diez unitarias; tres workflows y scripts de entrega/recuperación preparados. No hay datos humanos ni proveedor público elegido.

## Verificaciones ejecutadas

| Control | Resultado | Evidencia |
|---|---|---|
| Backend | 145 aprobadas, 0 errores/fallos/omitidas. Los warnings originales se conservan en el log. | [Log](backend-full.log), [JUnit](test-results.xml) |
| Cobertura backend | 2882/3200 ≈ 90.0625 %; líneas 2329/2500, ramas 553/700; umbral 81 % sin cambios. | [XML](coverage.xml), [HTML](htmlcov/index.html) |
| Playwright | 30/30 aprobadas, sin omitidas/flaky, 279,719 s. | [HTML](playwright-html/index.html), [matriz](MATRIZ_E2E.md), [JSON](playwright-results.json), [JUnit](playwright-junit.xml) |
| EN-002 | 15 casos posteriores verificados; cinco semillas para cada tamaño; frío 150/11 también comprobado. | [Método, tabla y fallos originales](RENDIMIENTO.md) |
| OSRM monopunto | HTTP 400 con una coordenada y HTTP 200 con dos idénticas, fuentes/destinos 0/0. | [Respuesta real](osrm-coordenada-unica.json) |
| Nuevas dependencias E2E | npm audit: 0 vulnerabilidades conocidas en el análisis. No es garantía de cero vulnerabilidades del sistema. | [JSON](npm-audit.json) |
| Disponibilidad local | 12/12 observaciones de dos endpoints de salud. No uptime mensual ni prueba suficiente de negocio. | [Ventana y muestras](disponibilidad-local.json) |
| Aplicación activa local | API existente reconstruida con la matriz probada; SHA verificado dentro del contenedor, salud 200 y dos consultas OSRM reales aprobadas. Respaldo privado validado; comparación de todas las filas originales sin cambios. No se modificó Docker Compose ni se desplegó producción pública. | [Verificación resumida sin datos privados](api-local-verificada.json) |
| Revalidación visual | Tres repeticiones GOLD aprobadas esperando teselas OSM HTTP 200; mapas Huancayo visibles en Chromium, Firefox y WebKit. Son repeticiones adicionales, no nuevos casos. | [HTML](playwright-visual-html/index.html), [JSON](playwright-visual-results.json) |
| Web Vitals | Nueve navegaciones sin interacción, tres por navegador, en el login local. Se conservan cargas frías, máximos y ausencias de LCP. | [Muestras y entorno](web-vitals-navegacion.json) |

## Reproducción y trazabilidad

Backend: `python -m pytest backend/tests -p no:cacheprovider --cov=backend/app --cov-config=.coveragerc --cov-report=xml:reports/coverage.xml --cov-report=html:reports/htmlcov --junitxml=reports/test-results.xml -q`, con DSN QA privado y esquema nuevo. No ejecutar contra la base operativa.

E2E: `npm ci --ignore-scripts`, instalar los tres navegadores y compilar Flutter para API8010; `npm run test:e2e`. Instrucciones en [tools/e2e](../../../../tools/e2e/README.md). Los casos usan cuentas aleatorias y esquemas nuevos, sin datos personales operativos. El GOLD utiliza UI para generar/confirmar/mapa/entregas/acuse y API para incidencia/replan/aprobación; verifica que la primera entrega no cambia.

SUS: `python -m unittest discover -s tools/sus -p 'test_*.py' -v`; diez casos algebraicos, no participantes. Workflows: actionlint y `bash -n`, no ejecución en GitHub. Flutter: la compilación web QA se ejecutó con Flutter3.47.7; se reutiliza la evidencia de 103 tests del 17/11 al no cambiar Dart. No se hizo SonarQube ni Android nuevo.

## Límites y cierre

Se conservan los fallos previos y no se eligieron solo semillas favorables. Tres destinos repetidos limitan representatividad; la campaña no demuestra carga concurrente ni todo Huancayo. Performance API no siempre expone LCP en canvas; no se fabrica una cifra. El 100 % observado es de los 30 casos de esta suite, no cobertura total del proyecto. Sin cinco respuestas SUS reales no hay media o grado; sin proveedor, URL y ejecuciones remotas no hay producción o CI/CD remoto acreditados. No se publicó GitHub ni se modificó Jira.

[Expediente Sprint 4](../../Sprint%204/README.md) · [README principal](../../../../README.md).
