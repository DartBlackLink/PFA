# Informe de cierre al corte técnico y lecciones aprendidas

**Proyecto:** EcoLogística Huancayo. **Responsable:** Jordy Steve Chancasanampa Torres. **Versión:** 1.0.0. **Fecha:** 18/11/2026. **Estado:** preparación de cierre; no acta de aceptación ni declaración de proyecto cerrado.

## 1. Informe final del proyecto al corte

EcoLogística apoya la planificación y operación de entregas urbanas en Huancayo y alrededores: ADMIN administra recursos, pedidos y rutas; REPARTIDOR consulta sus asignaciones, opera entregas y comunica incidencias. El informe relaciona el corte global con la inspección del Sprint 4; no reasigna funciones de otros sprints ni modifica sus documentos históricos.

| Área de desempeño | Línea base / plan | Real acreditado | Variación | Causa e impacto |
|---|---|---|---|---|
| Alcance | Backlog de 12 US y 5 EN, distribuido en seis sprints. | Incrementos web con pruebas operativas; Jira conserva 5 elementos Hecho y 12 En curso. | Aceptación de los incrementos no cerrada. | La verificación técnica no reemplaza decisión del responsable/docente. |
| Calidad | Funcionalidad, permisos y restricciones; Semana 14 añade E2E, SUS y CI/CD. | Corte 18/11: 145 backend, 30 E2E y cobertura combinada backend 90,0625 %. Se conserva Flutter 17/11: 103 aprobadas. | Tres navegadores acreditados localmente. La publicación manual y Chromium público se comprobaron el 19/11; SUS humano y CD automático siguen sin acreditarse. | Cierre parcial; no inferir evaluación humana de las pruebas automáticas. |
| Cronograma | Calendario oficial por sprint. | Sprint 4 existe sin fechas; no se celebró aceptación formal en esta actualización. | No calculable en días. | Sin calendario acordado no se afirma adelanto ni retraso. |
| Costos | Modelo académico: S/500 000 desarrollo y S/120 000 mantenimiento anual. | Sin gastos reales imputados o comprobantes en el expediente revisado. | No calculable en moneda. | Evitar presentar una estimación profesional supuesta como gasto ejecutado. |

### Riesgos, problemas e impedimentos

| Situación | Tratamiento / evidencia | Estado al corte |
|---|---|---|
| Datos temporales inconsistentes en asignaciones manuales. | Evaluación común, persistencia de ETA e indicadores, rechazo sin escritura ante horario inviable; resultados del 14/11. | Corrección técnica comprobada. |
| Muestra de rendimiento limitada a tres destinos repetidos. | Conservar datos originales y ampliar campaña sin cambiar el umbral para aprobar artificialmente. | Validación parcial de EN-002. |
| Dependencia de servicios públicos de mapa/ruteo. | Mostrar fallos recuperables y diferenciar estimación de tráfico real; exigir pruebas de red y trazas. | Riesgo vigente, no se promete disponibilidad de terceros. |
| Evidencia de Semana 14 incompleta. | E2E ya ejecutado y CI/CD configurado localmente; aplicar SUS a personas reales y, tras autorización, ejecutar Actions y desplegar en proveedor elegido. | No impide preparar documentación; sí impide declarar cierre integral. |

## 2. Informe final de lecciones aprendidas

| Área | Qué ocurrió y por qué | Práctica efectiva / recomendación concreta |
|---|---|---|
| Dinámica de trabajo | Una revisión solo visual ocultaba datos no persistidos. | Revisar cálculo, respuesta API, base y pantalla en una misma operación; conservar evidencia con fecha. |
| Evolución del alcance | Semana 14 exige instrumentos distintos a las pruebas previas. | Mantener matriz requisito/evidencia y registrar versión del documento; no renombrar pytest como E2E ni cobertura como SUS. |
| Precisión de estimación | Una ejecución rápida con puntos repetidos no representa toda la ciudad ni concurrencia. | Ampliar semillas y diversidad; informar tamaño, distribución y límites antes de comparar con el objetivo. |
| Procesos de calidad | El script esperaba 200 en vez de 201; después una campaña fría reveló consultas redundantes y el GOLD encontró la solicitud monopunto rechazada por OSRM. | Conservar fallos, revisar contrato y consultas reales; deduplicar sin redondear puntos, mantener índices y probar el caso estacionario antes de integrar. |
| Integración híbrida | El reporte necesita costos y calendario que Jira por sí solo no aporta. | Usar estado ágil para alcance y datos contables para EVM; no fabricar PV/EV/AC con SP. |
| Interesados | No consta una aceptación formal ni una muestra SUS recibida. | Preparar demostración y tareas por rol; solicitar opinión individual y registrar decisiones sin inventar reuniones. |

Estas lecciones amplían la visión de cierre; las preguntas y compromisos propios del Sprint 4 se conservan en su [retrospectiva](02%20Retrospectiva%20del%20Sprint%20V_1_0_0.md).

## 3. Transición y cierre administrativo

| Entregable o actividad | Situación acreditada | Condición para cierre |
|---|---|---|
| Código y migraciones | Fuentes organizadas en apps/web, apps/mobile, backend y database; PFA es copia de entrega. | Revisar integridad y versión aprobada antes de publicación. |
| Operación local | Aplicación funcional de desarrollo en D:/UC/App/ecologistica. | Mantener instrucciones, credenciales fuera de Git y respaldo privado probado. |
| Manuales | README e instrucciones locales existentes. | Validar recorrido por rol y que otra persona pueda seguirlos sin secretos en el repositorio. |
| Capacitación y entrega | No consta sesión formal ni firma de recepción. | Registrar fecha, asistentes autorizados, dudas y aceptación cuando ocurran. |
| Producción y soporte | URL pública operativa en Wasmer con Neon: https://ecologistica-huancayo-web.wasmer.app/. No consta acuerdo formal de soporte ni un SLA propio. | Definir responsables, monitoreo, recuperación y ventana de soporte; 30 días es propuesta de transición, no servicio ya prestado. |
| Cierre financiero | Sin gastos acreditados ni contratos a liquidar en el expediente. | Verificar obligaciones reales y documentar cierre si existen; no inventar proveedores o pagos. |
| Reconocimiento y evaluación de éxito | Desarrollo académico individual; decisión docente por realizar. | Comparar resultados con criterios, recoger aprendizaje y registrar decisión final. |

No se incorpora una firma ni fecha de aceptación ficticia. Primero corresponde completar evidencia y revisión formal; solo después formalizar transición, archivo y cierre. No se publica, despliega ni modifica Jira en este trabajo.

## Fuentes y evidencias

Guías de clase «Documentación de reporte híbrido — Proyecto To-Do list» y «Documentación de cierre de proyecto To-Do list», presentación «TP_2 19 Documentos de control y cierre proyecto», y lecturas 21/22, recibidas en Semana14. Se usan sus categorías, no sus cifras ilustrativas. Las rutas y huellas de las fuentes quedan en el registro privado de auditoría, sin publicar el cronograma con datos personales de otros alumnos.

Evidencia propia: [resultados del 14/11](../evidencias/20261114-desarrollo-integral/RESULTADOS.md), [resultados del 17/11](../evidencias/20261117-verificacion-final/RESULTADOS.md), [control híbrido](10%20Control%20h%C3%ADbrido%20V_1_0_0.md) y [control de requisitos](CONTROL_SEMANA14.md). Los videos suministrados no se presentan como visualizados o transcritos en esta auditoría documental.


[← Volver al README principal](../../../README.md)


## Revalidación técnica — 18/11/2026

Se añaden resultados posteriores sin sustituir los cortes históricos: 145 backend y 30 ejecuciones Playwright aprobadas, cobertura combinada backend 2882/3200 ≈ 90.0625 %. La campaña amplió a cinco semillas por cada tamaño 10/50/150; 15 casos posteriores a la deduplicación verificados. Se conservó el fallo frío inicial y se corrigió además el protocolo OSRM 1×1 con regresiones y GOLD posterior. La demanda sigue siendo sintética, sobre tres destinos, y no demuestra un SLA general.

El instrumento SUS y su calculador están implementados, pero no hay respuestas humanas; por tanto no hay puntuación SUS. Existen los tres workflows localmente, validados por actionlint y sintaxis Bash, sin ejecución en GitHub y todavía sin producción al corte del 18/11. La publicación manual posterior del 19/11 consta en las evidencias enlazadas. La declaración anterior sobre ausencia de estos archivos queda sustituida por este corte; sus resultados anteriores no se reetiquetan. Las mediciones web pueden carecer de una entrada LCP elegible en canvas y no se completan artificialmente. Continúan sin acreditarse costos reales, aceptación formal o cierre administrativo.

Consulte [resultados](../evidencias/20261118-semana14/RESULTADOS.md), [rendimiento](../evidencias/20261118-semana14/RENDIMIENTO.md), [análisis E2E](03%20Analisis%20PlayWrigth%20V_1_0_0.md), [usabilidad](04%20Usabilidad%20V_1_0_0.md) y [CI/CD](12%20Automatizaci%C3%B3n%20CI-CD%20V_1_0_0.md).


## Estado documental consolidado — 19/11/2026

La URL pública y la persistencia por roles ya se comprobaron en Wasmer y Neon; [resultado y límites](../evidencias/20261119-despliegue-publico/RESULTADOS.md). Esta evidencia actualiza el estado de publicación, sin alterar las cifras locales de rendimiento/cobertura, los costos no acreditados o el calendario no confirmado. SUS real, Actions/CD automático y aceptación permanecen abiertos en las [acciones de cierre](ACCIONES_PARA_CERRAR_SPRINT4.md).
