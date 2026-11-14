# Revisión del Sprint 6

**Proyecto:** EcoLogística Huancayo. **Responsable:** Jordy Steve Chancasanampa Torres. **Corte técnico:** 14/11/2026, America/Lima. **Versión:** 1.0.0.

## Historias de Usuario completadas en este Sprint

Se presentan elementos implementados/revalidados y candidatos a revisión técnica. La agrupación es una propuesta técnica documental: Jira solo contiene los sprints 1, 2 y 3 al corte. No se inventan fechas oficiales, SP aceptados, reuniones ni decisiones del docente. Implementación y verificación no equivalen a aceptación académica.

| Jira | Elemento | Evidencia de trabajo |
|---|---|---|
| [EHAPP-23](https://ecologistica.atlassian.net/browse/EHAPP-23) | US-011 — Preferencias de cliente | Nueva gestión de clientes/preferencias y selección en pedidos. |
| [EHAPP-24](https://ecologistica.atlassian.net/browse/EHAPP-24) | US-012 — Equivalencia ambiental | Factor y fuente persistidos; sin parámetros no se inventa resultado. |
| [EHAPP-18](https://ecologistica.atlassian.net/browse/EHAPP-18) | EN-004 — Experiencia y accesibilidad mínima | Widgets y navegador móvil; claro/oscuro, textos e iconos, sin certificación WCAG. |
| [EHAPP-22](https://ecologistica.atlassian.net/browse/EHAPP-22) | EN-005 — Pruebas y documentación | Regresión compartida, OpenAPI, cobertura y entrega local; aceptación externa separada. |

## Demostración del trabajo completado

1. ADMIN registró un cliente QA mediante el formulario, lo buscó y guardó preferencias 08:00–18:00 con referencia e instrucciones.
2. El horario con inicio igual a fin se rechazó. Se inactivó y reactivó el cliente desde la web y sus preferencias/pedidos permanecieron.
3. Pedidos permite buscar y seleccionar un cliente registrado; la regresión comprueba cliente_id persistido y rechazo de uno inactivo.
4. Se rechazó factor ambiental 0 y se configuró 8.887 kg CO₂ por galón US de gasolina con fuente EPA, como equivalencia teórica de combustión. No es un factor local medido ni una compensación real.
5. Se verificaron ausencia de factor, dato faltante, fuente y cálculo. Las pantallas y el modal fueron inspeccionados a 360 px en claro/oscuro. Las pruebas, OpenAPI y evidencia conservan sus alcances reales.

### Criterios de aceptación

La [matriz de aceptación](../MATRIZ_FINAL_BACKLOG_WEB.md) detalla GOLD, feliz, infeliz y borde por elemento y enlaza pruebas/código. El registro de las operaciones y capturas está en las [evidencias y resultados](../evidencias/20261114-desarrollo-integral/RESULTADOS.md).

### Definition of Done y decisión

Código, pruebas automatizadas y demostración técnica vinculados. La aceptación por el responsable/docente, el calendario Jira y la revisión humana no se sustituyen por este informe. SonarQube nuevo está bloqueado por credencial; la campaña ampliada de rendimiento y accesibilidad formal siguen identificadas por separado.

## Pendientes

Consultar [documento único de acciones externas y cierre](../ACCIONES_EXTERNAS_Y_CIERRE_WEB.md). No se modifica Jira ni se publica en GitHub en este trabajo.

[Índice](README.md)
