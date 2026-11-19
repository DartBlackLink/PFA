# Sprint 4 — Mapa, indicadores, rendimiento y expediente Semana 14

**Proyecto:** EcoLogística Huancayo. **Responsable:** Jordy Steve Chancasanampa Torres. **Versión documental:** 1.3.0. **Actualización:** 19/11/2026.

Sprint 4 (ID 70) ya existe en Jira y contiene EN-002 / EHAPP-14, US-006 / EHAPP-15 y US-007 / EHAPP-16: 15 SP originales, tres elementos En curso y sin fechas oficiales. Se conservan los cortes del 14/17/18 de noviembre y se incorpora la publicación comprobada del 19/11. No se declara aceptación docente ni cambio de estados Jira.

## Cuatro entregables de Semana 14

1. [Revisión del sprint](01%20Revisi%C3%B3n%20del%20Sprint%20V_1_0_0.md).
2. [Retrospectiva del sprint](02%20Retrospectiva%20del%20Sprint%20V_1_0_0.md).
3. [Análisis Playwright](03%20Analisis%20PlayWrigth%20V_1_0_0.md).
4. [Usabilidad SUS](04%20Usabilidad%20V_1_0_0.md).

La [web pública](https://ecologistica-huancayo-web.wasmer.app/) está operativa con Wasmer y Neon. Se conservan 30 ejecuciones Playwright locales del 18/11 y 12 comprobaciones de Chromium en la publicación del 19/11, con alcances separados. SUS no tiene respuestas humanas; Actions/CD automático y aceptación siguen pendientes.

## Anexos conservados y control/cierre

- [Informe de estado](01%20Informe%20de%20estado%20del%20proyecto%20V_1_0_0.md) y [registro de impedimentos](02%20Registro%20de%20Impedimentos%20V_1_0_0.md).
- [Calidad de código](05%20Calidad%20de%20c%C3%B3digo%20V_1_0_0.md), [seguridad OWASP](06%20Seguridad%20OWASP%20V_1_0_0.md), [accesibilidad WCAG](07%20Accesibilidad%20WCAG%20V_1_0_0.md), [trazabilidad](08%20Trazabilidad%20y%20versionamiento%20V_1_0_0.md) y [protocolo de rendimiento](09%20Plan%20de%20validaci%C3%B3n%20del%20rendimiento%20V_1_0_0.md).
- [Control híbrido: variaciones, EVM y tablero](10%20Control%20h%C3%ADbrido%20V_1_0_0.md).
- [Informe de cierre al corte y lecciones aprendidas](11%20Cierre%20y%20lecciones%20aprendidas%20V_1_0_0.md).
- [Correspondencia con la consigna y guías](CONTROL_SEMANA14.md) y [acciones necesarias para cerrar](ACCIONES_PARA_CERRAR_SPRINT4.md).

La [matriz de aceptación](../MATRIZ_FINAL_BACKLOG_WEB.md) conserva GOLD, feliz, infeliz y borde. Véanse [resultados del 14/11](../evidencias/20261114-desarrollo-integral/RESULTADOS.md) y [revalidación del 17/11](../evidencias/20261117-verificacion-final/RESULTADOS.md). No se altera documentación de otros sprints ni se duplica el árbol por el error ortográfico «Inplementación» de la consigna.


[← Volver al README principal](../../../README.md)


## Implementación y evidencia del 18/11

- [CI/CD y configuración de producción](12%20Automatizaci%C3%B3n%20CI-CD%20V_1_0_0.md).
- [Encuesta SUS lista para aplicar](instrumentos/Encuesta_SUS.html) y [procedimiento/cálculo](../../../tools/sus/README.md).
- [Resultados nuevos](../evidencias/20261118-semana14/RESULTADOS.md), [matriz E2E](../evidencias/20261118-semana14/MATRIZ_E2E.md) y [campaña de rendimiento](../evidencias/20261118-semana14/RENDIMIENTO.md).


## Actualización de publicación — 19/11/2026

La [web pública de EcoLogística Huancayo](https://ecologistica-huancayo-web.wasmer.app/) y FastAPI en Wasmer están conectados con Neon. Se comprobaron 41 operaciones/contratos API y 12 comprobaciones de Chromium; el repartidor confirmó por UI la recepción v2 y la última entrega. La persistencia se contrastó directamente en PostgreSQL. [Evidencias y límites](../evidencias/20261119-despliegue-publico/RESULTADOS.md).

Este corte sustituye la ausencia de URL/proveedor indicada al 18/11; los resultados históricos conservan su fecha. No se publicaron cambios en GitHub ni se ejecutó Actions. El workflow preparado para VPS requiere adaptarse a Wasmer y comprobarse; la carga actual fue manual. SUS sigue sin respuestas reales y la aceptación formal continúa por realizar. No se declaran aprobados esos requisitos por disponer de URL.

## Preparación de los dos requisitos restantes — 19/11/2026

La [guía para aplicar SUS](instrumentos/GUIA_APLICACION_SUS.md) permite organizar las cinco participaciones y conservar respuestas/observaciones reales. El [plan CI/CD actualizado](12%20Automatizaci%C3%B3n%20CI-CD%20V_1_0_0.md) distingue el workflow VPS existente de la adaptación técnica pendiente a Wasmer y especifica qué ejecuciones acreditarán el requisito. Esta actualización es solo documental: no se publicaron credenciales, no se ejecutó Actions y no se contabilizan respuestas prometidas como recibidas.

## Evidencia pública explicada — 19/11/2026

El [expediente visual de Semana 14](EVIDENCIAS_PUBLICAS_SEMANA14.md) enlaza las capturas de ADMIN, mapa de Huancayo y entregas del REPARTIDOR con las respuestas HTTP y persistencia de la misma prueba. Explica el estado previo al acuse y el estado final recibido; no atribuye a una captura de navegación una prueba completa de CRUD. Se reutilizan evidencias originales del 19/11, sin repetir operaciones ni incluir credenciales. SUS y Actions mantienen su estado pendiente de resultados propios.
