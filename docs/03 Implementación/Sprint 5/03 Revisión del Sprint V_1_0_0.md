# Revisión del Sprint 5

**Proyecto:** EcoLogística Huancayo. **Responsable:** Jordy Steve Chancasanampa Torres. **Corte técnico:** 14/11/2026, America/Lima. **Versión:** 1.0.0.

## Historias de Usuario completadas en este Sprint

Se presentan elementos implementados/revalidados y candidatos a revisión técnica. La agrupación es una propuesta técnica documental: Jira solo contiene los sprints 1, 2 y 3 al corte. No se inventan fechas oficiales, SP aceptados, reuniones ni decisiones del docente. Implementación y verificación no equivalen a aceptación académica.

| Jira | Elemento | Evidencia de trabajo |
|---|---|---|
| [EHAPP-19](https://ecologistica.atlassian.net/browse/EHAPP-19) | US-008 — Reporte PDF básico | Nueva exportación autenticada por ruta/versión. |
| [EHAPP-20](https://ecologistica.atlassian.net/browse/EHAPP-20) | US-010 — Incidencias operativas | Función heredada revalidada por botones; origen y resolución conservados. |
| [EHAPP-21](https://ecologistica.atlassian.net/browse/EHAPP-21) | US-009 — Reoptimización | Función heredada revalidada: pendientes, aprobación, acuse y primera entrega intacta. |
| [EHAPP-17](https://ecologistica.atlassian.net/browse/EHAPP-17) | EN-003 — Seguridad y privacidad | Permisos negativos, validación, análisis y actualización de dependencia afectada. |

## Demostración del trabajo completado

1. ADMIN abrió Reportes. Sin seleccionar ruta, la descarga permaneció deshabilitada. Seleccionó una planificación guardada y descargó PDF; se validó su estructura, contenido y render.
2. REPARTIDOR confirmó la primera entrega y registró una incidencia QA de congestión. ADMIN consultó esa incidencia, evaluó la alternativa y aprobó la versión 2.
3. El repartidor vio versión 2 pendiente de acuse, confirmó recepción y completó la entrega restante. El historial conservó la primera fecha. ADMIN registró la resolución.
4. Las consultas API posteriores verificaron FINALIZADA, versión recibida 2, dos entregas, resolución e aislamiento. El caso no mejoró distancia/tiempo y no se informó ahorro.
5. API anónima 401 y repartidor 403 en reportes/clientes. Se corrigió el pin afectado de OpenTelemetry y se volvió a auditar; no se atribuye un Sonar nuevo.

### Criterios de aceptación

La [matriz de aceptación](../MATRIZ_FINAL_BACKLOG_WEB.md) detalla GOLD, feliz, infeliz y borde por elemento y enlaza pruebas/código. El registro de las operaciones y capturas está en las [evidencias y resultados](../evidencias/20261114-desarrollo-integral/RESULTADOS.md).

### Definition of Done y decisión

Código, pruebas automatizadas y demostración técnica vinculados. La aceptación por el responsable/docente, el calendario Jira y la revisión humana no se sustituyen por este informe. SonarQube nuevo está bloqueado por credencial; la campaña ampliada de rendimiento y accesibilidad formal siguen identificadas por separado.

## Pendientes

Consultar [documento único de acciones externas y cierre](../ACCIONES_EXTERNAS_Y_CIERRE_WEB.md). No se modifica Jira ni se publica en GitHub en este trabajo.

[Índice](README.md)
