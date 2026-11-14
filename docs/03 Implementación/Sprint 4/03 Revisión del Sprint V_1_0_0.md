# Revisión del Sprint 4

**Proyecto:** EcoLogística Huancayo. **Responsable:** Jordy Steve Chancasanampa Torres. **Corte técnico:** 14/11/2026, America/Lima. **Versión:** 1.1.0.

## Historias de Usuario completadas en este Sprint

Se presentan elementos implementados/revalidados y candidatos a revisión técnica. La agrupación es una propuesta técnica documental: Jira solo contiene los sprints 1, 2 y 3 al corte. No se inventan fechas oficiales, SP aceptados, reuniones ni decisiones del docente. Implementación y verificación no equivalen a aceptación académica.

| Jira | Elemento | Evidencia de trabajo |
|---|---|---|
| [EHAPP-15](https://ecologistica.atlassian.net/browse/EHAPP-15) | US-006 — Mapa y paradas de Huancayo | Mapa previo revalidado por navegador, sin fabricar ubicaciones. |
| [EHAPP-16](https://ecologistica.atlassian.net/browse/EHAPP-16) | US-007 — Dashboard esencial | Indicadores de servidor, ausencias explícitas y ventanas previstas/reales. |
| [EHAPP-14](https://ecologistica.atlassian.net/browse/EHAPP-14) | EN-002 — Rendimiento del motor | Medición integrada QA con OSRM real; límites de muestra declarados. |

## Demostración del trabajo completado

1. ADMIN seleccionó dos pedidos QA con destinos de Huamanmarca y Constitución, equipo y salida; generó la propuesta genética, abrió su mapa y confirmó la asignación.
2. REPARTIDOR recibió su ruta propia, la inició y operó sus entregas; el otro repartidor recibió 404 para ese recurso.
3. El resumen y Reportes consultan indicadores reales de PostgreSQL. Una ruta histórica manual sin combustible/CO₂ no se convierte en cero. Las nuevas asignaciones manuales guardan esos indicadores y ETA.
4. Endpoint integrado: 150 pedidos sintéticos,15 equipos, tres destinos públicos repetidos, OSRM real, 16.649722 s frente a 45 s. Reoptimización de 3 pendientes: 1.780739 s frente a 30 s. Excluye render/proxy; muestra limitada.
5. Se inspeccionaron temas y controles a 360 px; no se atribuye una certificación de accesibilidad ni aceptación del docente.

### Criterios de aceptación

La [matriz de aceptación](../MATRIZ_FINAL_BACKLOG_WEB.md) detalla GOLD, feliz, infeliz y borde por elemento y enlaza pruebas/código. El registro de las operaciones y capturas está en las [evidencias y resultados](../evidencias/20261114-desarrollo-integral/RESULTADOS.md).

### Definition of Done y decisión

Código, pruebas automatizadas y demostración técnica vinculados. La aceptación por el responsable/docente, el calendario Jira y la revisión humana no se sustituyen por este informe. SonarQube nuevo está bloqueado por credencial; la campaña ampliada de rendimiento y accesibilidad formal siguen identificadas por separado.

## Pendientes

Consultar [documento único de acciones externas y cierre](../ACCIONES_EXTERNAS_Y_CIERRE_WEB.md). No se modifica Jira ni se publica en GitHub en este trabajo.

[Índice](README.md)
