# Registro de impedimentos — Sprint 6

**Proyecto:** EcoLogística Huancayo. **Responsable:** Jordy Steve Chancasanampa Torres. **Corte técnico de las correcciones:** 14/11/2026, America/Lima. **Actualización documental:** 16/11/2026. **Versión del contenido:** 1.1.0.

## Criterio de registro

Este registro conserva dificultades técnicas reales encontradas al desarrollar o validar el alcance del sprint: errores de código, lógica, dependencias, integración, datos o pruebas. Cada fila identifica el problema, su causa, la corrección y el estado alcanzado. Un problema corregido permanece como antecedente; no se presenta como un bloqueo abierto.

La falta de una credencial de análisis no se registra como defecto de la aplicación. Las actividades externas de revisión y cierre se mantienen en el [documento de acciones](../ACCIONES_EXTERNAS_Y_CIERRE_WEB.md).

## Problemas técnicos encontrados y solución

| ID / tipo | Problema e impacto | Causa identificada | Corrección aplicada | Estado al corte técnico |
|---|---|---|---|---|
| IMP-S6-01 · Modelo de datos y formulario | Registrar el nombre del cliente en cada pedido no ofrecía una gestión web de preferencias asociada al mismo cliente. Sin un selector, el flujo no garantizaba reutilizar explícitamente su identidad al registrar otro pedido. | El formulario y la interfaz de gestión no cubrían el flujo de clientes/preferencias por `cliente_id`. Es una limitación anterior documentada; no se afirma que se hubieran encontrado o borrado duplicados reales. | Se incorporó gestión de clientes y preferencias, selector de cliente registrado y conservación de `cliente_id` en el pedido. El servidor valida el estado del cliente y rechaza uno inactivo; el formulario puede reutilizar su referencia. | CORREGIDO en el flujo implementado. Se verificaron asociación persistida, rechazo de cliente inactivo y alta por formulario con el mismo cliente. |
| IMP-S6-02 · Preparación del respaldo y destino de base de datos | El primer respaldo se obtuvo de la base heredada indicada por `POSTGRES_DB`, que no era la base operativa usada por FastAPI. Ese archivo no protegía los datos activos antes de la migración. | Se había asumido que el nombre de inicialización de PostgreSQL coincidía con la conexión efectiva de la aplicación. No hubo corrupción de PostgreSQL ni pérdida acreditada de datos. | Se comprobó la conexión activa `ecologistica_operativa`, se generó su respaldo correcto y se contrastaron las filas originales con lecturas posteriores. La migración 0008 se aplicó de forma aditiva; los respaldos privados no se publican. | CORREGIDO en el procedimiento de respaldo. El control de integridad conserva las filas originales de negocio de las 18 tablas del respaldo. |
| IMP-S6-03 · Montaje de pruebas de interfaz | La primera ejecución focalizada de widgets falló al intentar pulsar un control fuera del área visible y al finalizar con temporizadores pendientes del proveedor de autenticación. Impedía obtener un resultado de prueba confiable. | El test no desplazaba el formulario hasta la acción y su montaje asíncrono no respetaba el ciclo de vida de los temporizadores. Estos fallos pertenecían al montaje de prueba, no demuestran un desbordamiento visual de la web. | Se corrigió el desplazamiento/visibilidad en el test y el montaje asíncrono del proveedor. No se eliminaron las validaciones del producto. Después se verificaron Clientes, Reportes y el modal a 360 px en claro/oscuro, también en navegador real. | CORREGIDO en las pruebas. Los siete casos focalizados y la suite Flutter final quedaron aprobados. |

## Verificación de las correcciones

- **IMP-S6-01:** `test_order_reuses_registered_client_and_rejects_inactive_client` y `test_client_preferences_gold_update_clear_and_invalid` en [pruebas backend](../../../backend/tests/test_reporting_clients.py). Evidencia de formulario guardado: [detalle del pedido](../evidencias/20261114-desarrollo-integral/capturas/pedido-web-persistido.jpg); [matriz de operaciones](../evidencias/20261114-desarrollo-integral/MATRIZ_OPERACIONES.md).
- **IMP-S6-02:** [integridad final](../evidencias/20261114-desarrollo-integral/integridad-final.json) y apartado «Flujo por botones y datos conservados» de [Resultados](../evidencias/20261114-desarrollo-integral/RESULTADOS.md#flujo-por-botones-y-datos-conservados). Los dumps y logs con datos privados se conservan fuera del repositorio.
- **IMP-S6-03:** [pruebas de los módulos](../../../apps/web/test/completion_modules_test.dart), [log final Flutter](../evidencias/20261114-desarrollo-integral/flutter-full-final.log), [modal a 360 px](../evidencias/20261114-desarrollo-integral/capturas/modal-ambiental-360.png) y [clientes en tema oscuro](../evidencias/20261114-desarrollo-integral/capturas/cliente-inactivo-360-oscuro.png). El fallo focalizado y su repetición aprobada permanecen en los registros locales de desarrollo; no se inventa un defecto visual para justificarlo.

## Gestión del registro

Responsable de seguimiento: Jordy. Los casos anteriores se agrupan por el alcance documental de este sprint; no se inventan fechas de ceremonias ni una aceptación del docente. La actualización del 16/11 es documental y no representa una nueva ejecución de pruebas.

Las correcciones se respaldan en la regresión compartida del 14/11: **141 pruebas backend y 93 Flutter aprobadas**. No se suman nuevamente por cada fila ni por cada sprint. Consulte los [resultados y sus límites](../evidencias/20261114-desarrollo-integral/RESULTADOS.md) y la [retrospectiva del sprint](04%20Retrospectiva%20del%20Sprint%20V_1_0_0.md) para los compromisos preventivos.

[Índice](README.md)
