# Informe de estado del proyecto — Sprint 5

**Proyecto:** EcoLogística Huancayo. **Responsable:** Jordy Steve Chancasanampa Torres. **Corte técnico:** 14/11/2026, America/Lima. **Sprint documental:** 5. **Versión:** 1.0.0.

**Periodo del informe:** corte técnico del 14/11/2026 correspondiente únicamente al alcance de este sprint propuesto. No sustituye el calendario oficial por crear/confirmar en Jira.

**Objetivo:** reportes y operación trazable para la operación web ADMIN/REPARTIDOR de Huancayo.

## Estado del proyecto

| Variable | Estado comprobable |
|---|---|
| Alcance | Elementos detallados abajo; diferencia entre desarrollo nuevo y revalidación de código existente. |
| Cronograma | Trabajo técnico y pruebas del 14/11 registrados; sin fechas oficiales ni velocidad de sprint inventadas. |
| Costos | Infraestructura local existente. No hay parte de horas ni gasto exclusivo acreditado para este sprint. |
| Calidad | Regresión compartida de 141 pruebas backend y 93 Flutter; los resultados no se suman una vez por cada sprint. Cobertura backend: 90.0313479624 % (2872/3190, líneas + ramas); líneas 2321/2492, ramas 551/698. No es cobertura de todo Flutter ni un Sonar nuevo. |

### Elementos de línea base

US = historia de usuario; EN = habilitador técnico; EHAPP = clave estable de Jira. La numeración vigente no sustituye retroactivamente los identificadores históricos.

| Jira | Elemento | Trabajo realizado o revalidado |
|---|---|---|
| [EHAPP-19](https://ecologistica.atlassian.net/browse/EHAPP-19) | US-008 — Reporte PDF básico | Nueva exportación autenticada por ruta/versión. |
| [EHAPP-20](https://ecologistica.atlassian.net/browse/EHAPP-20) | US-010 — Incidencias operativas | Función heredada revalidada por botones; origen y resolución conservados. |
| [EHAPP-21](https://ecologistica.atlassian.net/browse/EHAPP-21) | US-009 — Reoptimización | Función heredada revalidada: pendientes, aprobación, acuse y primera entrega intacta. |
| [EHAPP-17](https://ecologistica.atlassian.net/browse/EHAPP-17) | EN-003 — Seguridad y privacidad | Permisos negativos, validación, análisis y actualización de dependencia afectada. |

## Cambios y mejoras realizados

El cliente HTTP solo manejaba JSON; un PDF necesita una respuesta binaria autenticada, validación de Content-Type y firma %PDF antes de descargar. Se añadió ese camino y se comprobó el rechazo de HTML exitoso y errores JSON. En la operación real, la versión 2 no se consideró recibida al aprobar: se esperó el acuse del repartidor y se conservó la fecha de la primera entrega.

Se realizó ADMIN → REPARTIDOR → ADMIN → REPARTIDOR por botones con FastAPI/PostgreSQL y OSRM. La incidencia se identificó como simulada, tuvo resolución y no se presentó una alternativa sin mejora como ahorro. El PDF descargado fue parseado y renderizado, no solo abierto.

## Riesgos

Las estimaciones no son mediciones físicas; los datos de validación están identificados como QA. El proveedor vial público puede no estar disponible. Una muestra favorable no garantiza todos los tiempos futuros.

## Próximas acciones

La agrupación es una propuesta técnica documental: Jira solo contiene los sprints 1, 2 y 3 al corte. No se inventan fechas oficiales, SP aceptados, reuniones ni decisiones del docente. Implementación y verificación no equivalen a aceptación académica. Las acciones no técnicas y la campaña ampliada se mantienen en [acciones externas y cierre](../ACCIONES_EXTERNAS_Y_CIERRE_WEB.md). La evidencia concreta está en las [evidencias y resultados](../evidencias/20261114-desarrollo-integral/RESULTADOS.md).

[Índice](README.md)
