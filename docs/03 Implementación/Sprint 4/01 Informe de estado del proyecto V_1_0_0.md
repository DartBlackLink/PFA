# Informe de estado del proyecto — Sprint 4

**Proyecto:** EcoLogística Huancayo. **Responsable:** Jordy Steve Chancasanampa Torres. **Corte técnico:** 14/11/2026, America/Lima. **Sprint documental:** 4. **Versión del contenido:** 1.2.0. **Actualización documental:** 18/11/2026.

**Periodo del informe:** corte técnico del 14/11/2026 correspondiente únicamente al alcance del Sprint 4. Actualización de seguimiento al 18/11: Sprint 4 creado en Jira, sin fechas oficiales; no se inventa un periodo de ejecución.

**Objetivo:** mapa, indicadores y rendimiento para la operación web ADMIN/REPARTIDOR de Huancayo.

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
| [EHAPP-15](https://ecologistica.atlassian.net/browse/EHAPP-15) | US-006 — Mapa y paradas de Huancayo | Mapa previo revalidado por navegador, sin fabricar ubicaciones. |
| [EHAPP-16](https://ecologistica.atlassian.net/browse/EHAPP-16) | US-007 — Dashboard esencial | Indicadores de servidor, ausencias explícitas y ventanas previstas/reales. |
| [EHAPP-14](https://ecologistica.atlassian.net/browse/EHAPP-14) | EN-002 — Rendimiento del motor | Medición integrada QA con OSRM real; límites de muestra declarados. |

## Cambios y mejoras realizados

Un trazado visible no acredita una planificación temporal válida. La asignación manual guardaba distancia/tiempo, pero no combustible, CO₂ ni ETA por entrega; el cambio de horario tampoco revalidaba toda la ventana. Se reutilizó la evaluación de restricciones del motor, se guardaron los indicadores y ETA y se comprobó rechazo sin modificar la ruta ante una salida inviable. El cumplimiento previsto incluye atención completa, no solo la llegada.

Se conservó el mapa de Huancayo y el historial; se revalidó el flujo por navegador y se diferenció ETA de hora real. El benchmark usa carreteras reales y demanda sintética identificada, sin llamarla tráfico en vivo ni una muestra de 150 direcciones distintas.

## Riesgos

Las estimaciones no son mediciones físicas; los datos de validación están identificados como QA. El proveedor vial público puede no estar disponible. Una muestra favorable no garantiza todos los tiempos futuros.

## Próximas acciones

Al 18/11 Jira contiene seis sprints; Sprint 4 (ID 70) agrupa EHAPP-14, EHAPP-15 y EHAPP-16, con 15 SP originales y estado En curso. No se inició ni cerró el sprint en esta revisión documental. No se inventan fechas oficiales, SP aceptados, reuniones ni decisiones del docente. Implementación y verificación no equivalen a aceptación académica. Las acciones no técnicas y la campaña ampliada se mantienen en [acciones externas y cierre](../ACCIONES_EXTERNAS_Y_CIERRE_WEB.md). La evidencia concreta está en las [evidencias y resultados](../evidencias/20261114-desarrollo-integral/RESULTADOS.md).

[Índice](README.md)


## Seguimiento según la guía de reporte híbrido — 18/11/2026

| Categoría | Elemento | Situación del Sprint 4 |
|---|---|---|
| Alcance | Logros, cambios y calidad | Mapa/indicadores revalidados; asignación manual con ETA e indicadores corregida. Semana 14 exige además E2E, SUS y CI/CD; no se declaran cumplidos mediante pruebas previas. |
| Cronograma | Plan no completado, causa e impacto | EN-002 tiene una campaña limitada y la aceptación no está cerrada; no hay fechas Sprint 4 en Jira. Impacto: no es posible afirmar cumplimiento de plazo. |
| Cronograma | Acción correctiva/preventiva | Acordar calendario y campaña ampliada; comprobar criterio/evidencia antes de marcar cierre. |
| Costos | Gasto, variación e impacto | Sin horas ni desembolsos reales acreditados por sprint. No hay base para calcular variación financiera ni consumo de contingencia. |
| Costos | Acción correctiva/preventiva | Separar presupuesto académico de gastos reales; registrar fecha, concepto y comprobante si existe gasto. |
| Próximo periodo | Logros y costos previstos | Preparar campaña de tres navegadores, evaluación SUS y pipelines; no hay costo comprometido o desembolso aprobado en este expediente. |
| Riesgos y problemas | Situación nueva | Confundir evidencia manual con Playwright o cobertura con SUS produciría una conclusión inválida. Los defectos técnicos corregidos permanecen en el registro de impedimentos. |
| Comentarios | Decisión | Documentación preparada; revisión formal y evidencias adicionales por completar. No publicación ni despliegue en esta tarea. |

El [reporte de control híbrido](10%20Control%20h%C3%ADbrido%20V_1_0_0.md) desarrolla variaciones, valor ganado y tablero visual sin inventar datos financieros ni curvas diarias.

[← Volver al README principal](../../../README.md)


## Revalidación técnica — 18/11/2026

Se añaden resultados posteriores sin sustituir los cortes históricos: 145 backend y 30 ejecuciones Playwright aprobadas, cobertura combinada backend 2882/3200 ≈ 90.0625 %. La campaña amplió a cinco semillas por cada tamaño 10/50/150; 15 casos posteriores a la deduplicación verificados. Se conservó el fallo frío inicial y se corrigió además el protocolo OSRM 1×1 con regresiones y GOLD posterior. La demanda sigue siendo sintética, sobre tres destinos, y no demuestra un SLA general.

El instrumento SUS y su calculador están implementados, pero no hay respuestas humanas; por tanto no hay puntuación SUS. Existen los tres workflows localmente, validados por actionlint y sintaxis Bash, sin ejecución en GitHub y todavía sin producción al corte del 18/11. La publicación manual posterior del 19/11 consta en las evidencias enlazadas. La declaración anterior sobre ausencia de estos archivos queda sustituida por este corte; sus resultados anteriores no se reetiquetan. Las mediciones web pueden carecer de una entrada LCP elegible en canvas y no se completan artificialmente. Continúan sin acreditarse costos reales, aceptación formal o cierre administrativo.

Consulte [resultados](../evidencias/20261118-semana14/RESULTADOS.md), [rendimiento](../evidencias/20261118-semana14/RENDIMIENTO.md), [análisis E2E](03%20Analisis%20PlayWrigth%20V_1_0_0.md), [usabilidad](04%20Usabilidad%20V_1_0_0.md) y [CI/CD](12%20Automatizaci%C3%B3n%20CI-CD%20V_1_0_0.md).


## Estado documental consolidado — 19/11/2026

La URL pública y la persistencia por roles ya se comprobaron en Wasmer y Neon; [resultado y límites](../evidencias/20261119-despliegue-publico/RESULTADOS.md). Esta evidencia actualiza el estado de publicación, sin alterar las cifras locales de rendimiento/cobertura, los costos no acreditados o el calendario no confirmado. SUS real, Actions/CD automático y aceptación permanecen abiertos en las [acciones de cierre](ACCIONES_PARA_CERRAR_SPRINT4.md).
