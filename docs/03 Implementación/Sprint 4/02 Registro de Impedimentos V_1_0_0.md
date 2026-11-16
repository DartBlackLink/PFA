# Registro de impedimentos — Sprint 4

**Proyecto:** EcoLogística Huancayo. **Responsable:** Jordy Steve Chancasanampa Torres. **Corte técnico de las correcciones:** 14/11/2026, America/Lima. **Actualización documental:** 16/11/2026. **Versión del contenido:** 1.2.0.

## Criterio de registro

Este registro conserva dificultades técnicas reales encontradas al desarrollar o validar el alcance del sprint: errores de código, lógica, dependencias, integración, datos o pruebas. Cada fila identifica el problema, su causa, la corrección y el estado alcanzado. Un problema corregido permanece como antecedente; no se presenta como un bloqueo abierto.

La falta de una credencial de análisis no se registra como defecto de la aplicación. Las actividades externas de revisión y cierre se mantienen en el [documento de acciones](../ACCIONES_EXTERNAS_Y_CIERRE_WEB.md).

## Problemas técnicos encontrados y solución

| ID / tipo | Problema e impacto | Causa identificada | Corrección aplicada | Estado al corte técnico |
|---|---|---|---|---|
| IMP-S4-01 · Lógica e integración API | La asignación manual guardaba distancia y tiempo, pero no ETA por entrega, combustible ni CO₂. Además, el contrato `RutaRead` no exponía combustible/CO₂, por lo que un valor guardado podía no llegar al cliente. Esto impedía consultar indicadores completos de una ruta nueva. | El flujo manual no utilizaba la evaluación completa del motor; faltaban campos en la respuesta API. | Se incorporó `evaluate_manual`, con tiempos viales por tramo y restricciones del motor; se persistieron ETA, combustible y CO₂ y se añadieron los campos a `RutaRead`. No se inventaron indicadores para rutas históricas sin esos datos. | CORREGIDO. La prueba de creación manual comprueba indicadores y ETA en la respuesta. |
| IMP-S4-02 · Validación temporal | Cambiar la salida de una ruta no revalidaba completamente la ventana de atención de los pedidos. Comprobar únicamente la llegada podía aceptar una entrega cuya atención terminara fuera de horario. | La validación del cambio de horario y el cálculo de cumplimiento no aplicaban de forma uniforme ETA + tiempo de servicio. | Se reutilizó la evaluación de restricciones para recalcular el horario y las ETA; el cumplimiento previsto considera la atención completa. Una propuesta inviable se rechaza sin modificar la ruta ni asignar pedidos. | CORREGIDO. Se verifica rechazo HTTP 422, conservación de la salida anterior y actualización de ETA ante un horario válido. |
| IMP-S4-03 · Instrumentación de rendimiento | El instrumento de medición declaró error al recibir HTTP 201 en la generación de una propuesta válida. Interrumpió la comprobación posterior aunque la creación había funcionado. | El script esperaba HTTP 200, en desacuerdo con el contrato de creación de la API. No era un error del algoritmo ni una caída de FastAPI. | Se corrigió la expectativa a 201 y se continuó desde la propuesta guardada. Se conservó el tiempo original de 16,6497217 s, sin repetir la muestra para escoger un resultado favorable. | CORREGIDO en el instrumento. La muestra sigue limitada a una semilla y tres destinos públicos repetidos; no acredita la campaña ampliada. |

## Verificación de las correcciones

- **IMP-S4-01 y 02:** [pruebas de reportes y asignación](../../../backend/tests/test_reporting_clients.py): `test_manual_route_calculates_metrics_and_checks_full_windows`, `test_manual_impossible_window_and_missing_legs_do_not_assign` y `test_planned_compliance_requires_whole_service_inside_window`. Código: [evaluación manual](../../../backend/app/services/manual_planning.py), [rutas](../../../backend/app/api/routes/routes.py) y [contrato API](../../../backend/app/schemas.py).
- **IMP-S4-03:** [medición integrada](../evidencias/20261114-desarrollo-integral/benchmark-integrado.json) y explicación del error del instrumento en [Resultados → Rendimiento medido](../evidencias/20261114-desarrollo-integral/RESULTADOS.md#rendimiento-medido). La respuesta original se conserva en el registro local de continuidad; no se atribuye ese archivo auxiliar a GitHub.

## Gestión del registro

Responsable de seguimiento: Jordy. Los casos anteriores se agrupan por el alcance documental de este sprint; no se inventan fechas de ceremonias ni una aceptación del docente. La actualización del 16/11 es documental y no representa una nueva ejecución de pruebas.

Las correcciones se respaldan en la regresión compartida del 14/11: **141 pruebas backend y 93 Flutter aprobadas**. No se suman nuevamente por cada fila ni por cada sprint. Consulte los [resultados y sus límites](../evidencias/20261114-desarrollo-integral/RESULTADOS.md) y la [retrospectiva del sprint](04%20Retrospectiva%20del%20Sprint%20V_1_0_0.md) para los compromisos preventivos.

[Índice](README.md)
