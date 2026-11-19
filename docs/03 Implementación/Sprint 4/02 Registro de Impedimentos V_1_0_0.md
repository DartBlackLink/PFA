# Registro de impedimentos — Sprint 4

**Proyecto:** EcoLogística Huancayo. **Responsable:** Jordy Steve Chancasanampa Torres. **Corte técnico de las correcciones:** 14/11/2026, America/Lima. **Actualización técnica y documental:** 18/11/2026. **Versión del contenido:** 1.3.0.

## Criterio de registro

Este registro conserva dificultades técnicas reales encontradas al desarrollar o validar el alcance del sprint: errores de código, lógica, dependencias, integración, datos o pruebas. Cada fila identifica el problema, su causa, la corrección y el estado alcanzado. Un problema corregido permanece como antecedente; no se presenta como un bloqueo abierto.

La falta de una credencial de análisis no se registra como defecto de la aplicación. Las actividades externas de revisión y cierre se mantienen en el [documento de acciones](../ACCIONES_EXTERNAS_Y_CIERRE_WEB.md).

## Problemas técnicos encontrados y solución

| ID / tipo | Problema e impacto | Causa identificada | Corrección aplicada | Estado al corte técnico |
|---|---|---|---|---|
| IMP-S4-01 · Lógica e integración API | La asignación manual guardaba distancia y tiempo, pero no ETA por entrega, combustible ni CO₂. Además, el contrato `RutaRead` no exponía combustible/CO₂, por lo que un valor guardado podía no llegar al cliente. Esto impedía consultar indicadores completos de una ruta nueva. | El flujo manual no utilizaba la evaluación completa del motor; faltaban campos en la respuesta API. | Se incorporó `evaluate_manual`, con tiempos viales por tramo y restricciones del motor; se persistieron ETA, combustible y CO₂ y se añadieron los campos a `RutaRead`. No se inventaron indicadores para rutas históricas sin esos datos. | CORREGIDO. La prueba de creación manual comprueba indicadores y ETA en la respuesta. |
| IMP-S4-02 · Validación temporal | Cambiar la salida de una ruta no revalidaba completamente la ventana de atención de los pedidos. Comprobar únicamente la llegada podía aceptar una entrega cuya atención terminara fuera de horario. | La validación del cambio de horario y el cálculo de cumplimiento no aplicaban de forma uniforme ETA + tiempo de servicio. | Se reutilizó la evaluación de restricciones para recalcular el horario y las ETA; el cumplimiento previsto considera la atención completa. Una propuesta inviable se rechaza sin modificar la ruta ni asignar pedidos. | CORREGIDO. Se verifica rechazo HTTP 422, conservación de la salida anterior y actualización de ETA ante un horario válido. |
| IMP-S4-03 · Instrumentación de rendimiento | El instrumento de medición declaró error al recibir HTTP 201 en la generación de una propuesta válida. Interrumpió la comprobación posterior aunque la creación había funcionado. | El script esperaba HTTP 200, en desacuerdo con el contrato de creación de la API. No era un error del algoritmo ni una caída de FastAPI. | Se corrigió la expectativa a 201 y se continuó desde la propuesta guardada. Se conservó el tiempo original de 16,6497217 s, sin repetir la muestra para escoger un resultado favorable. | CORREGIDO en el instrumento. Ese registro del 14/11 corresponde a una semilla. La campaña posterior del 18/11 se acredita por separado en IMP-S4-04; ambas conservan tres destinos repetidos. |
| IMP-S4-04 · Rendimiento y protocolo vial | La muestra 150/11 falló en frío con 503; después, el GOLD encontró que una replanificación estacionaria también fallaba. | La matriz dividía 165 posiciones repetidas en 25 bloques aunque solo había tres lugares. Al deduplicar, una matriz 1×1 enviaba una coordenada, pero OSRM exige al menos dos. | Se consulta cada coordenada exacta una vez y se expande la matriz a los índices originales. En bloques 1×1 se envía dos veces el mismo punto con selección 0/0; se conserva la validación del proveedor y no se inventan distancia o ubicación. | CORREGIDO: cuatro regresiones nuevas, 145 backend y GOLD por tres navegadores; fallo inicial y respuesta OSRM 400/200 conservados. |
| IMP-S4-05 · Integración de pruebas | Dos pruebas de asignación devolvieron 503 mientras funcionaban los demás casos. | La web E2E y el proveedor controlado de integración compartían 8090; las peticiones podían llegar al proceso equivocado. | Web E2E separada en 8095, API QA en 8010 y stub en 8090; esquemas de prueba independientes. No se cambiaron validaciones para forzar el aprobado. | CORREGIDO en la instrumentación; regresión completa posterior aprobada. No fue pérdida de datos ni error de la base operativa. |

## Verificación de las correcciones

- **IMP-S4-01 y 02:** [pruebas de reportes y asignación](../../../backend/tests/test_reporting_clients.py): `test_manual_route_calculates_metrics_and_checks_full_windows`, `test_manual_impossible_window_and_missing_legs_do_not_assign` y `test_planned_compliance_requires_whole_service_inside_window`. Código: [evaluación manual](../../../backend/app/services/manual_planning.py), [rutas](../../../backend/app/api/routes/routes.py) y [contrato API](../../../backend/app/schemas.py).
- **IMP-S4-03:** [medición integrada](../evidencias/20261114-desarrollo-integral/benchmark-integrado.json) y explicación del error del instrumento en [Resultados → Rendimiento medido](../evidencias/20261114-desarrollo-integral/RESULTADOS.md#rendimiento-medido). La respuesta original se conserva en el registro local de continuidad; no se atribuye ese archivo auxiliar a GitHub.

## Gestión del registro

Responsable de seguimiento: Jordy. Los casos anteriores se agrupan por el alcance documental de este sprint; no se inventan fechas de ceremonias ni una aceptación del docente. La actualización del 16/11 es documental y no representa una nueva ejecución de pruebas.

Las correcciones se respaldan en la regresión compartida del 14/11: **141 pruebas backend y 93 Flutter aprobadas**. No se suman nuevamente por cada fila ni por cada sprint. Consulte los [resultados y sus límites](../evidencias/20261114-desarrollo-integral/RESULTADOS.md) y la [retrospectiva del sprint](02%20Retrospectiva%20del%20Sprint%20V_1_0_0.md) para los compromisos preventivos.

[Índice](README.md)

[← Volver al README principal](../../../README.md)


**Evidencia nueva del 18/11:** [resultados](../evidencias/20261118-semana14/RESULTADOS.md), [campaña](../evidencias/20261118-semana14/RENDIMIENTO.md), [regresiones de matriz](../../../backend/tests/test_matrix_duplicates.py) y [matriz E2E](../evidencias/20261118-semana14/MATRIZ_E2E.md). Las filas anteriores mantienen su corte histórico; la actualización no inventa nuevas ceremonias ni registra la ausencia de encuesta/producción como errores de programación.
