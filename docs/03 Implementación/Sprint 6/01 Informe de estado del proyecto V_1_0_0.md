# Informe de estado del proyecto — Sprint 6

**Proyecto:** EcoLogística Huancayo. **Responsable:** Jordy Steve Chancasanampa Torres. **Corte técnico:** 14/11/2026, America/Lima. **Sprint documental:** 6. **Versión:** 1.0.0.

**Periodo del informe:** corte técnico del 14/11/2026 correspondiente únicamente al alcance de este sprint propuesto. No sustituye el calendario oficial por crear/confirmar en Jira.

**Objetivo:** clientes, equivalencia y entrega verificable para la operación web ADMIN/REPARTIDOR de Huancayo.

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
| [EHAPP-23](https://ecologistica.atlassian.net/browse/EHAPP-23) | US-011 — Preferencias de cliente | Nueva gestión de clientes/preferencias y selección en pedidos. |
| [EHAPP-24](https://ecologistica.atlassian.net/browse/EHAPP-24) | US-012 — Equivalencia ambiental | Factor y fuente persistidos; sin parámetros no se inventa resultado. |
| [EHAPP-18](https://ecologistica.atlassian.net/browse/EHAPP-18) | EN-004 — Experiencia y accesibilidad mínima | Widgets y navegador móvil; claro/oscuro, textos e iconos, sin certificación WCAG. |
| [EHAPP-22](https://ecologistica.atlassian.net/browse/EHAPP-22) | EN-005 — Pruebas y documentación | Regresión compartida, OpenAPI, cobertura y entrega local; aceptación externa separada. |

## Cambios y mejoras realizados

Registrar un nombre en cada pedido no conserva una preferencia asociada al mismo cliente. Se agregó gestión de clientes y selección por cliente_id; se probó el rechazo de clientes inactivos y la asociación persistida. Una equivalencia sin factor/fuente sería arbitraria: se exige el conjunto completo y se muestran los supuestos.

Se conservaron datos e identidad visual, se verificaron los controles nuevos a 360 px en claro/oscuro y se mantuvieron baja lógica y reactivación. La configuración ambiental registra autor y fecha; no se incluyeron contraseñas en evidencias.

## Riesgos

Las estimaciones no son mediciones físicas; los datos de validación están identificados como QA. El proveedor vial público puede no estar disponible. Una muestra favorable no garantiza todos los tiempos futuros.

## Próximas acciones

La agrupación es una propuesta técnica documental: Jira solo contiene los sprints 1, 2 y 3 al corte. No se inventan fechas oficiales, SP aceptados, reuniones ni decisiones del docente. Implementación y verificación no equivalen a aceptación académica. Las acciones no técnicas y la campaña ampliada se mantienen en [acciones externas y cierre](../ACCIONES_EXTERNAS_Y_CIERRE_WEB.md). La evidencia concreta está en las [evidencias y resultados](../evidencias/20261114-desarrollo-integral/RESULTADOS.md).

[Índice](README.md)
