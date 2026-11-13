# Verificación de Huancayo — 03/11/2026

Ámbito confirmado: Huancayo, El Tambo, Chilca y alrededores urbanos hacia Pilcomayo, San Agustín de Cajas, Huancán, Huayucachi y Sapallanga. Envolvente técnica: latitud -12.18 a -11.94; longitud -75.32 a -75.12. No equivale a límites administrativos. Zona horaria America/Lima.

## Recuperación y correcciones

Se recuperaron 26 fuentes guardadas frente al respaldo de la intervención; el recuento anterior de 20 no incluía todos los archivos nuevos y pruebas. Los cambios estaban en stage, no desplegados en el principal. Se recuperaron los contenedores QA existentes sin recrear ni vaciar sus datos.

Se restringen búsqueda/reversa, pedido, origen, reporte y recálculo al ámbito aprobado. La UI rechaza puntos exteriores. Las rutas históricas exteriores se conservan para consulta, sin relocalizarlas ni operarlas. Se completó el guard que impedía operar esas rutas pero todavía permitía cambiar su horario; se añadió el caso negativo correspondiente.

## Resultados comprobados

| Capa | Resultado |
|---|---|
| Backend pertinente antes de regresión | 23 aprobadas; 1 advertencia de deprecación del cliente de pruebas |
| Backend completo tras corrección | 127 aprobadas, 1 advertencia, 74.22 s |
| Líneas | 2261/2410 = 93.817427% |
| Ramas | 478/604 = 79.139073% |
| Cobertura combinada Coverage.py | (2261+478)/(2410+604) ×100 = 90.87591240875912408759124088% (90,88 % redondeado) |
| Flutter actual | 73 aprobadas en la repetición final; análisis sin incidencias; Web QA release compilada en 135,9 s |
| Bandit | 0 hallazgos, sin errores de análisis; no equivale a garantía de seguridad |
| Casos nativos, análisis estático | Sin incidencias; ejecución Android no aprobada |
| Android actual | No aprobado en esta versión: consultar ANDROID.md y el registro real; no acredita GOLD móvil. |
| SonarQube | No se atribuye el análisis histórico a este código. Ver SONARQUBE.md. |

La cobertura corresponde al backend configurado, no a todo el proyecto ni a una garantía de ausencia de errores. HTML (archivo local de auditoría: `index.html`), [XML](coverage.xml), [JUnit](test-results.xml).

## GOLD Web real, simulación controlada

Navegador real, Flutter Web 8081, FastAPI 8002 y PostgreSQL QA ecologistica_huancayo_20261103. Proveedores Photon/OSM y OSRM reales; usuario, vehículo y pedidos QA nuevos, sin entrega física.

1. ADMIN eligió tres destinos públicos obtenidos del geocodificador: Plaza de la Constitución, Parque de la Identidad Huanca y Plaza Huamanmarca. El algoritmo genético propuso 7,469 km y 10,96 min viales más atención. Se revisó mapa OSM con calles y se confirmó la asignación.
2. REPARTIDOR consultó su única ruta, acusó versión 1, inició 07:44 y completó Parque de la Identidad Huanca 07:44. La salida planificada 00:11 procede del dataset anterior conservado, no es hora física de salida ni demuestra puntualidad.
3. Reportó congestión explícitamente sintética, demora3 min y coordenada pública del parque. ADMIN recibió aviso sin F5 y abrió la ruta.
4. ADMIN calculó desde esa posición QA actualizada, conservando la entrega completada y verificando los dos pendientes. Comparación: 4,04 km/11,10 min contra 4,04 km/11,10 min. Diferencia0: no se demuestra ahorro ni desvío alrededor de una calle cerrada.
5. ADMIN aprobó versión 2. El repartidor la recibió por consulta periódica y acusó 07:50. Las dos entregas restantes se confirmaron 07:50 y 07:51. Se resolvió la incidencia dejando motivo auditable.
6. Ruta e372ad53-dea0-4b64-ae13-d38b6a4aec0a: FINALIZADA, versión 2, recibida 2, tres entregas únicas. Reiniciar API preservó resultados e historial. La primera fecha de entrega permanece idéntica a su snapshot anterior.
7. HTTP real: repartidor→configuraciónADMIN403; anónimo→rutas401; ID inexistente/no accesible404. La regresión cubre además acceso a recursos de otro repartidor, concurrencia, propuestas vencidas y caída de proveedor.

## Alcance de integración

Fuentes verificadas copiadas con comparación SHA y respaldo a D:/UC/App/ecologistica y PFA/backend + apps/web + apps/mobile. Los informes anteriores y Sprints1/2 se conservan. La instancia QA 8081 carga este código y geometría local. El build/despliegue principal 8080/API8000 conserva su decisión previa pendiente: sincronizar fuentes no actualiza automáticamente su imagen. No hubo commit, push ni cambios de Jira.

## Reproducción

Backend pertinente: `python -m pytest backend/tests/test_huancayo_area.py backend/tests/test_route_operation.py -q --no-cov`.

Regresión: `python -m pytest backend/tests --cov --cov-config=tools/quality/coverage.ini --cov-report=term-missing --cov-report=xml:reports/coverage.xml --cov-report=html:reports/htmlcov --junitxml=reports/test-results.xml -q`. Ejecutada exclusivamente en la base temporal protegida ecologistica_revision_20261007, separada de la funcional y principal.

Flutter: `flutter analyze`; `flutter test --machine`; compilación QA release con API_BASE_URL apuntando a8002. Las claves QA permanecen fuera del repositorio y no se distribuye el APK de instrumentación.
