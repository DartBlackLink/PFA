# Revisión del sprint

**Nombre del Proyecto:** EcoLogística Huancayo.

**Líder del Proyecto:** Chancasanampa Torres, Jordy Steve.

**Sprint:** 4. **Versión del contenido:** 1.3.0. **Actualización documental:** 18/11/2026. Se conservan los cortes del 14/17 de noviembre y se añade la validación automatizada del 18/11, sin inventar una nueva reunión de revisión.

## Historias de Usuario completadas en este Sprint

La tabla identifica el incremento implementado y sus límites. No se declara cierre de historias: al corte de Jira del 18/11, Sprint 4 (ID 70) está creado, sin fechas oficiales, y sus tres elementos siguen En curso. Completar una comprobación técnica no equivale a cumplir toda la Definition of Done ni a aceptación del docente.

| Elemento / alcance | Criterios comprobados | Trazabilidad y decisión |
|---|---|---|
| [EHAPP-15 / US-006](https://ecologistica.atlassian.net/browse/EHAPP-15) — Visualizar rutas en mapa, 5 SP | Recorrido vial y paradas de Huancayo; lectura de la ruta propia; comparación y cambio de versión; no inventar la ubicación de un pedido. | Mapa heredado y revalidado; ajustes relacionados en el [commit 5089c788](https://github.com/DartBlackLink/PFA/commit/5089c7881cc62e68378999528c93402a94fb50f3). La corrección de contraste del 17/11 permanece local, sin commit de cierre. |
| [EHAPP-16 / US-007](https://ecologistica.atlassian.net/browse/EHAPP-16) — Consultar dashboard esencial, 5 SP | Indicadores consultados al servidor; distinción entre estimación y hora real; datos ausentes no convertidos en cero; persistencia de ETA e indicadores en nuevas asignaciones manuales. | Implementación en el [commit 5089c788](https://github.com/DartBlackLink/PFA/commit/5089c7881cc62e68378999528c93402a94fb50f3). Comprobaciones en resultados del 14/11. |
| [EHAPP-14 / EN-002](https://ecologistica.atlassian.net/browse/EHAPP-14) — Rendimiento del motor, 5 SP | Ejecución integrada con proveedor vial y registro de tiempos; generación 150 pedidos/15 equipos y replanificación de tres pendientes. | Habilitador técnico, no tercera historia funcional. Campaña del 18/11: tamaños 10/50/150, cinco semillas y 15 casos verificados tras corregir consultas redundantes. Demanda sintética sobre tres destinos; aceptación y representatividad general no acreditadas. |

Los cuatro escenarios por elemento —GOLD, feliz, infeliz y borde— están en la [matriz de aceptación](../MATRIZ_FINAL_BACKLOG_WEB.md). Su existencia documental no significa que todos hayan sido aceptados formalmente. Los enlaces al commit muestran trabajo integrado; no se presentan como actas de aprobación.

## Demostración del trabajo completado

**Entorno y evidencia:** los cortes del 14/17/18 corresponden a la web local con FastAPI y PostgreSQL. Desde el 19/11 también se comprobó la [web pública](https://ecologistica-huancayo-web.wasmer.app/) en Wasmer con Neon; véanse [pruebas y persistencia](../evidencias/20261119-despliegue-publico/RESULTADOS.md). Los [resultados del 14/11](../evidencias/20261114-desarrollo-integral/RESULTADOS.md) y la [revalidación del 17/11](../evidencias/20261117-verificacion-final/RESULTADOS.md) describen operaciones reales por navegador. La segunda revalida el mapa dentro de un flujo transversal, sin imputar al Sprint 4 el desarrollo de incidencias y reoptimización del Sprint 5.

1. ADMIN generó una propuesta con destinos de Huancayo, consultó su mapa y confirmó la asignación.
2. REPARTIDOR consultó su ruta, confirmó recepción, inició y registró entregas. El acceso de otro repartidor a un recurso ajeno devolvió 404 en el corte del 14/11.
3. Se contrastaron indicadores con la API y su persistencia. Las nuevas asignaciones manuales incluyen ETA, combustible y CO₂ estimados; una ausencia histórica se conserva como ausencia.
4. La medición integrada del 14/11 registró 16,649722 s para 150 pedidos/15 equipos, frente al objetivo de 45 s, y 1,780739 s para tres pendientes, frente a 30 s. Son demandas sintéticas sobre tres puntos públicos repetidos y una semilla 42; no representan 150 direcciones distintas ni tiempos de carga del navegador.
5. El 17/11 se comprobó una ruta finalizada con dos entregas y versión 2 recibida. La alternativa fue 0,35 km y 0,35 min mayor y se aprobó únicamente como QA: no demuestra ahorro.

**Revalidación técnica del 18/11:** 145 backend y 30 E2E aprobadas. Se comprobó generación/confirmación/mapa y operación del repartidor por UI; incidencia/replan/aprobación por API y acuse por UI. La primera entrega conserva su fecha tras la versión 2. El [expediente nuevo](../evidencias/20261118-semana14/RESULTADOS.md) incluye resultados, código y límites. La deduplicación conserva los 165 índices y usa solo tres puntos físicos; la solicitud 1×1 repite el mismo punto para cumplir el protocolo OSRM, sin inventar una ubicación. Código del 18/11 local, sin commit de cierre publicado.

**Retroalimentación:** se incorporan las observaciones docentes sobre separación de sprints, informe de un solo sprint, impedimentos técnicos, cuatro escenarios de aceptación y compromisos preventivos. No consta acta de una nueva demostración a stakeholders, encuesta SUS ni aceptación de este incremento. Las comprobaciones locales no se describen como reunión celebrada.

## Pendientes

Se implementó y ejecutó la suite Playwright en tres navegadores, se completaron cinco semillas por tamaño y se prepararon los tres workflows. Falta aplicar SUS a usuarios reales, ejecutar CI/pruebas en GitHub y adaptar/ejecutar el despliegue automático para Wasmer. La publicación manual y la URL pública ya se comprobaron el 19/11; no se ha autorizado ni realizado un push nuevo a GitHub en esta actualización. La muestra geográfica continúa limitada a tres destinos públicos repetidos. El [control de Semana 14](CONTROL_SEMANA14.md) y las [acciones de cierre](ACCIONES_PARA_CERRAR_SPRINT4.md) identifican responsables, evidencia necesaria y condición de aceptación. No se declara el Sprint 4 cerrado.


[← Volver al README principal](../../../README.md)


## Actualización de publicación — 19/11/2026

La [web pública de EcoLogística Huancayo](https://ecologistica-huancayo-web.wasmer.app/) y FastAPI en Wasmer están conectados con Neon. Se comprobaron 41 operaciones/contratos API y 12 comprobaciones de Chromium; el repartidor confirmó por UI la recepción v2 y la última entrega. La persistencia se contrastó directamente en PostgreSQL. [Evidencias y límites](../evidencias/20261119-despliegue-publico/RESULTADOS.md).

Este corte sustituye la ausencia de URL/proveedor indicada al 18/11; los resultados históricos conservan su fecha. No se publicaron cambios en GitHub ni se ejecutó Actions. El workflow preparado para VPS requiere adaptarse a Wasmer y comprobarse; la carga actual fue manual. SUS sigue sin respuestas reales y la aceptación formal continúa por realizar. No se declaran aprobados esos requisitos por disponer de URL.

## Evidencia pública explicada — 19/11/2026

El [expediente visual de Semana 14](EVIDENCIAS_PUBLICAS_SEMANA14.md) enlaza las capturas de ADMIN, mapa de Huancayo y entregas del REPARTIDOR con las respuestas HTTP y persistencia de la misma prueba. Explica el estado previo al acuse y el estado final recibido; no atribuye a una captura de navegación una prueba completa de CRUD. Se reutilizan evidencias originales del 19/11, sin repetir operaciones ni incluir credenciales. SUS y Actions mantienen su estado pendiente de resultados propios.
