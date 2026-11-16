# Registro de impedimentos — Sprint 5

**Proyecto:** EcoLogística Huancayo. **Responsable:** Jordy Steve Chancasanampa Torres. **Corte técnico de las correcciones:** 14/11/2026, America/Lima. **Actualización documental:** 16/11/2026. **Versión del contenido:** 1.1.0.

## Criterio de registro

Este registro conserva dificultades técnicas reales encontradas al desarrollar o validar el alcance del sprint: errores de código, lógica, dependencias, integración, datos o pruebas. Cada fila identifica el problema, su causa, la corrección y el estado alcanzado. Un problema corregido permanece como antecedente; no se presenta como un bloqueo abierto.

La falta de una credencial de análisis no se registra como defecto de la aplicación. Las actividades externas de revisión y cierre se mantienen en el [documento de acciones](../ACCIONES_EXTERNAS_Y_CIERRE_WEB.md).

## Problemas técnicos encontrados y solución

| ID / tipo | Problema e impacto | Causa identificada | Corrección aplicada | Estado al corte técnico |
|---|---|---|---|---|
| IMP-S5-01 · Integración y formato de respuesta | El cliente HTTP solo decodificaba JSON y no tenía un camino para recibir el PDF binario. Ese contrato impedía implementar una descarga correcta desde Reportes. | Se reutilizaba un tratamiento de respuesta JSON para un documento `application/pdf`. | Se añadió respuesta binaria autenticada con comprobación de Content-Type y firma `%PDF-`; la descarga web usa bytes y Blob. Los errores JSON conservan su mensaje y una respuesta HTML con HTTP 200 se rechaza como PDF inválido. | CORREGIDO. Pruebas de bytes válidos, HTML y errores JSON; descarga real revisada mediante parseo y render. |
| IMP-S5-02 · Función incompleta del módulo | Reportes era una pantalla informativa, sin selección de una ruta persistida ni exportación. Abrir la pantalla no permitía completar la operación comprometida por US-008. | Faltaba conectar la interfaz con consultas de informes y generación de PDF en el backend. Es una carencia funcional del estado anterior, no una descarga que se hubiera probado exitosamente antes. | Se añadieron consultas protegidas para ADMIN, selección paginada y PDF por ruta/versión; el botón permanece deshabilitado sin selección. Una ruta inválida o cancelada se rechaza y los indicadores ausentes se identifican explícitamente. | CORREGIDO en el alcance implementado. Se descargó un PDF desde el botón y se verificó su contenido. |
| IMP-S5-03 · Versión de dependencia y seguridad | La auditoría del lock identificó `opentelemetry-api` 1.45.1 con el hallazgo CVE-2026-126360. Mantener esa versión dejaba una dependencia conocida como afectada en la entrega. | El archivo de versiones fijadas aún referenciaba la versión vulnerable. El hallazgo no demuestra que se hubiera explotado la aplicación. | Se actualizó el pin a 1.45.2, se instaló la versión corregida en los entornos usados y se repitieron la auditoría y la regresión. Se conservaron ambos informes. | CORREGIDO para el hallazgo identificado. La auditoría final no encontró vulnerabilidades conocidas en las dependencias examinadas; no equivale a garantía universal de seguridad. |

## Verificación de las correcciones

- **IMP-S5-01:** [pruebas Flutter](../../../apps/web/test/completion_modules_test.dart), casos «Descarga rechaza HTML exitoso y conserva errores JSON» y «Descarga devuelve bytes PDF sin decodificar como JSON». Código: [ApiClient](../../../apps/web/lib/core/network/api_client.dart) y [descarga web](../../../apps/web/lib/core/download/download_web.dart).
- **IMP-S5-02:** [pantalla Reportes](../../../apps/web/lib/features/reports/reports_screen.dart), [API de informes](../../../backend/app/api/routes/reports.py) y [pruebas backend](../../../backend/tests/test_reporting_clients.py), incluyendo `test_gold_report_from_confirmed_plan_and_pdf`, permisos y texto escapado. Evidencia: [PDF verificado](../evidencias/20261114-desarrollo-integral/reporte-ruta-verificado.pdf) y [render inspeccionado](../evidencias/20261114-desarrollo-integral/capturas/pdf-descargado.png).
- **IMP-S5-03:** [auditoría anterior](../evidencias/20261114-desarrollo-integral/dependency-audit-before.json), [auditoría posterior](../evidencias/20261114-desarrollo-integral/dependency-audit.json) y [versiones fijadas](../../../backend/requirements.lock.txt).

## Gestión del registro

Responsable de seguimiento: Jordy. Los casos anteriores se agrupan por el alcance documental de este sprint; no se inventan fechas de ceremonias ni una aceptación del docente. La actualización del 16/11 es documental y no representa una nueva ejecución de pruebas.

Las correcciones se respaldan en la regresión compartida del 14/11: **141 pruebas backend y 93 Flutter aprobadas**. No se suman nuevamente por cada fila ni por cada sprint. Consulte los [resultados y sus límites](../evidencias/20261114-desarrollo-integral/RESULTADOS.md) y la [retrospectiva del sprint](04%20Retrospectiva%20del%20Sprint%20V_1_0_0.md) para los compromisos preventivos.

[Índice](README.md)
