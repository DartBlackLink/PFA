# Acciones para el cierre formal del Sprint 4

**Proyecto:** EcoLogística Huancayo. **Responsable:** Jordy Steve Chancasanampa Torres. **Versión:** 1.3.0. **Corte:** 19/11/2026.

## Completado y verificable

| Entregable | Resultado real | Evidencia |
|---|---|---|
| Documentación y plantillas | Revisión, retrospectiva, Playwright, SUS, control híbrido y cierre preparados con su estructura docente. No se inventa aceptación. | [Índice](README.md), [control de requisitos](CONTROL_SEMANA14.md). |
| Validación local del 18/11 | 145 backend; cobertura combinada 90,0625 %; 30 ejecuciones Playwright en tres motores; campaña de cinco semillas por tamaño. | [Resultados del laboratorio](../evidencias/20261118-semana14/RESULTADOS.md). |
| Publicación web | Wasmer sirve Flutter Web y FastAPI; Neon conserva PostgreSQL. HTTPS y URL pública operativa. Este punto ya no requiere elegir proveedor. | [Abrir aplicación](https://ecologistica-huancayo-web.wasmer.app/), [despliegue comprobado](../evidencias/20261119-despliegue-publico/RESULTADOS.md). |
| Flujo en el entorno público | 41 comprobaciones API y 12 de Chromium; recepción v2 y última entrega por interfaz, primera entrega conservada y lectura final directa de PostgreSQL. | [Informe y capturas](../evidencias/20261119-despliegue-publico/RESULTADOS.md). |
| Preparación de SUS | Encuesta anónima, CSV, unificador y calculador; diez pruebas del calculador y validación del formulario. | [Encuesta](instrumentos/Encuesta_SUS.html), [aplicación y cálculo](../../../tools/sus/README.md). No son respuestas humanas. |
| Preparación CI/CD | Tres workflows y sus controles locales; la entrega preparada originalmente usa VPS. | [Configuración y estado](12%20Automatizaci%C3%B3n%20CI-CD%20V_1_0_0.md). Todavía no es automatización Wasmer ejecutada. |

## Lo que todavía falta acreditar

| Acción | Cómo realizarla | Evidencia necesaria | Responsable |
|---|---|---|---|
| Aplicar SUS a ≥5 personas reales | Probar tareas por rol en la web pública con cuentas autorizadas y datos de demostración; obtener consentimiento y una respuesta anónima por persona. Unir CSV y ejecutar el calculador. | Respuestas originales, contribuciones por ítem, puntuación individual, promedio, grado y observaciones de tareas. No usar fixtures ni orientar respuestas para superar 68. | Jordy y participantes. |
| Ejecutar CI y pruebas en GitHub | Revisar secretos/diff y publicar cuando se autorice; ejecutar ci.yml y tests.yml en el SHA publicado. | URLs de ejecuciones reales y artifacts de pruebas. Un badge sin ejecución no acredita resultado. | Jordy, con autorización de publicación GitHub. |
| Adaptar y ejecutar CD para Wasmer | Sustituir la entrega VPS del workflow de producción por la integración Wasmer; configurar credenciales privadas autorizadas y publicar el mismo código que pasó CI/pruebas. Comprobar salud y roles al terminar. | Ejecución real de deploy-production.yml, versión/paquetes desplegados y URL funcionando después del despliegue automático. | Jordy y configuración de las cuentas. |
| Registrar revisión y aceptación | Presentar entregables y recoger observaciones reales del docente; confirmar calendario y estados Jira. | Decisión o acta real, sin cerrar historias únicamente por pruebas técnicas. | Jordy y docente. |

## Seguimiento de control y cierre

La variedad geográfica, carga y accesibilidad humana se amplían según lo acordado; la muestra de tres destinos repetidos no acredita todo Huancayo. Los tiempos/cobertura locales no se presentan como mediciones del servidor Wasmer. Para EVM/cierre administrativo se necesitan costos y decisiones reales, o una no aplicabilidad justificada; no se inventan PV/EV/AC, pagos o firmas.

**Estado:** la publicación manual está realizada. Aún faltan SUS real, CI/CD ejecutado y aceptación para declarar acreditada toda Semana 14. No se hizo commit, push ni cambio Jira al actualizar estos documentos.

[← Volver al README principal](../../../README.md)

## Acuerdo de trabajo posterior — 19/11/2026

Se solicitó trabajar **solo la documentación**, sin publicar tokens ni accesos. El responsable reunirá cinco respuestas SUS. Para realizarlo se incorpora la [guía de aplicación](instrumentos/GUIA_APLICACION_SUS.md); los resultados se calcularán al recibir los CSV reales. La [especificación CI/CD para Wasmer](12%20Automatizaci%C3%B3n%20CI-CD%20V_1_0_0.md) detalla la adaptación y sus evidencias, pero no sustituye su implementación ni ejecución. Por tanto, ninguno de los dos requisitos se marca completado por esta actualización. No se hace commit, push ni cambio Jira.
