# Matriz final del backlog web — aceptación y evidencia

**Proyecto:** EcoLogística Huancayo. **Responsable:** Jordy Steve Chancasanampa Torres. **Corte técnico:** 14/11/2026, America/Lima.

**Alcance:** web ADMIN/REPARTIDOR. Se conserva la numeración actual de Jira y el historial previo. GOLD describe el flujo completo; feliz una alternativa válida; infeliz el rechazo; borde los límites. Las pruebas citadas corresponden a D y su copia verificada en PFA, no a un APK nuevo.

| Jira / elemento | GOLD | Feliz | Infeliz | Borde | Prueba y evidencia |
|---|---|---|---|---|---|
| EHAPP-8 / EN-001 | Arranque de API/Web y migración en QA limpia | Reconstrucción de servicios existentes | Configuración ausente rechazada | Secretos fuera de fuente/artefacto | INICIAR_WEB.ps1; migraciones; prueba QA y deploy logs |
| EHAPP-9 / US-001 | ADMIN y REPARTIDOR entran y operan en sesiones separadas | Restauración de sesión válida | 401/403 y ruta ajena: 404 | Bloqueos 5 s / 10 s / 300 s; sesión caducada | test_integration.py; test_security.py; widget_test.dart; flujo navegador |
| EHAPP-10 / US-002 | Registrar/editar/consultar flota | Baja lógica/reactivación | Placa repetida y capacidad inválida | Capacidad > 0, rangos y agenda | test_integration.py; test_security.py; fleet_redesign_test.dart; antecedente UI del 13/11 |
| EHAPP-11 / US-003 | Conductor y cuenta asociados correctamente | Editar disponibilidad y consultar perfil propio | DNI/turno inválido; rol no autorizado | Turnos y solapamiento en asignación | test_integration.py; test_security.py; tests de operación |
| EHAPP-12 / US-004 | Pedido con punto de Huancayo, carga y ventana guardados | Edición pendiente con cliente registrado | Sin ubicación o cliente inactivo: 422; asignado: 409 | Coordenadas/zona, ventana completa y capacidad | test_order_update.py; test_huancayo_area.py; test_reporting_clients.py |
| EHAPP-13 / US-005 | Dos pedidos reales QA → propuesta vial → confirmación | Múltiples equipos bajo restricciones | Inviabilidad no asigna; propuesta obsoleta: 409 | 150 pedidos/15 equipos y límites de parámetros | test_genetic.py; test_optimization_api.py; benchmark y capturas |
| EHAPP-15 / US-006 | Mapa propio con origen, trazado y secuencia de Huancayo | Comparación de versiones e historial | Coordenada ausente no se inventa; ajeno 404 | Geometría completa dentro del perímetro | test_huancayo_area.py; route_map_lifecycle_test.dart; capturas web |
| EHAPP-16 / US-007 | Resumen y ruta con distancia/fuel/CO₂/ventanas | Ruta vigente o finalizada; valores cero válidos | Ausencia no se convierte en cero ni 100 % | ETA + atención; última versión/tramo pendiente | test_reporting_clients.py; completion_modules_test.dart; reportes web |
| EHAPP-14 / EN-002 | 150/15 integrado OSRM: 16.649722s | Replan medido de 3 pendientes:1.780739s | Errores de proveedor seguros y sin asignar | Topes 45 s / 30 s medidos solo en esta muestra | benchmark-integrado.json; test_matrix.py; no campaña de 5 semillas |
| EHAPP-19 / US-008 | Ruta confirmada → PDF con versión e indicadores | PDF con un indicador ausente explícito | Sin selección no descarga; cancelada: 409; roles 403 | Texto escapado, varias páginas y bytes válidos | test_reporting_clients.py; completion_modules_test.dart; PDF descargado/render |
| EHAPP-20 / US-010 | Reporte QA desde ruta propia → ADMIN → resolución | Tipo/posición/demora admitidos | Payload incompleto/ajeno rechazado | Mismo evento idempotente; contenido cambiado: 409 | test_route_operation.py; test_traffic_replanning.py; flujo-web-final.json |
| EHAPP-21 / US-009 | Primera entrega → incidencia → propuesta → aprobación → acuse → final | Alternativa factible sin mejora indicada expresamente | Ubicación caducada/vía cerrada/inviable conserva ruta | Versión antigua: 409, acuse real e historial inmutable | test_traffic_replanning.py; replanning_ui_test.dart; flujo web por botones |
| EHAPP-17 / EN-003 | Permisos reales en servidor y validación previa a escritura | Lecturas autorizadas propias | Anónimo401/rol 403/BOLA404; datos inválidos422 | Abuso/login, tamaño de payload y dependencia corregida | test_security.py; Bandit; dependency-audit antes/después; secretos |
| EHAPP-23 / US-011 | Cliente creado por web y preferencias asociadas | Preferencia sin horario; editar estado/reactivar | Inicio>=fin, horario parcial o cliente inexistente | Longitudes 500; búsqueda literal %; cliente_id sin duplicar | test_reporting_clients.py; completion_modules_test.dart; capturas clientes |
| EHAPP-24 / US-012 | Emisiones ÷ factor documentado, con unidad/fuente | Desactivar parámetro y mostrar no disponible | Factor 0/negativo/NaN/incompleto: 422 | CO₂ 0 es 0; falta CO₂/factor no se inventa | test_reporting_clients.py; modal y PDF; fuente EPA |
| EHAPP-18 / EN-004 | Flujos críticos y modal accesibles en 360 px | Temas claro/oscuro y desplazamiento | Errores expresados con texto, no solo color | Widgets a 360/768/1440 px; sin garantía de WCAG completa | responsive_ui_test.dart; ui_regression_test.dart; capturas a 360 px |
| EHAPP-22 / EN-005 | 141 pruebas backend + 93 pruebas Flutter y entrega con evidencia | Migración en esquema aislado y OpenAPI actualizado | Gate no aprobado ficticiamente; error del runner conservado | Cobertura real 90.03135%, no porcentaje artificial | XML/HTML/JUnit y matriz; aceptación externa separada |

## Cómo comprobarlo

- Código de pruebas: [backend/tests](../../backend/tests) y [apps/web/test](../../apps/web/test).
- [Resultados, comandos y archivos verificables](evidencias/20261114-desarrollo-integral/RESULTADOS.md).
- [Matriz de operaciones por pantalla](evidencias/20261114-desarrollo-integral/MATRIZ_OPERACIONES.md) separa navegador/API/widgets y no atribuye un alta web no repetida a esta sesión.
- [Distribución propuesta de sprints](PLAN_FINAL_SPRINTS_WEB.md) y [acciones para aceptación/cierre](ACCIONES_EXTERNAS_Y_CIERRE_WEB.md).

No se etiqueta cada combinación de toda entrada posible como probada. Los casos infelices y de borde tienen regresión automatizada; las operaciones por botones se identifican en su matriz. No se declara cero errores posibles ni todos los sprints aceptados.
