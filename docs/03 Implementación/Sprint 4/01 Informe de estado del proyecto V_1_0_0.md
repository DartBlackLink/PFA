# Informe de estado del proyecto — Sprint 4

**Proyecto:** EcoLogística Huancayo. **Responsable:** Jordy Steve Chancasanampa Torres. **Corte técnico:** 14/11/2026, America/Lima. **Sprint documental:** 4. **Versión:** 1.1.0.

**Periodo del informe:** corte técnico del 14/11/2026 correspondiente únicamente al alcance de este sprint propuesto. No sustituye el calendario oficial por crear/confirmar en Jira.

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

La agrupación es una propuesta técnica documental: Jira solo contiene los sprints 1, 2 y 3 al corte. No se inventan fechas oficiales, SP aceptados, reuniones ni decisiones del docente. Implementación y verificación no equivalen a aceptación académica. Las acciones no técnicas y la campaña ampliada se mantienen en [acciones externas y cierre](../ACCIONES_EXTERNAS_Y_CIERRE_WEB.md). La evidencia concreta está en las [evidencias y resultados](../evidencias/20261114-desarrollo-integral/RESULTADOS.md).

[Índice](README.md)
