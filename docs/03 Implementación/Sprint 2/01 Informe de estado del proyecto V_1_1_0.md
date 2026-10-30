[Índice de implementación](../README.md) · [README del proyecto](../../../README.md)

# Informe de estado — Sprint 2

**Proyecto:** EcoLogística Huancayo — caso DistriRápido S.A.C.

**Responsable:** Jordy Steve Chancasanampa Torres. **Sprint:** 2. **Versión:** 1.1.0. **Revisión correctiva:** 30/10/2026.

**Periodo del informe técnico:** 07–09/10/2026, fechas de las evidencias originales asociadas a este sprint. Esta revisión separa el informe combinado; no inventa ceremonias ni aceptación docente posterior.

## Estado del proyecto

| Variable de control | Estado exclusivo de este sprint |
|---|---|
| Alcance | Flota — EHAPP-10 / US-002 según contexto actualizado; Repartidores — ID Jira por reconciliar; LEG-20261009/US-004; Pedidos — EHAPP-12 / US-004 según contexto actualizado. Se informa capacidad técnica y su evidencia; los SP aceptados requieren decisión de aceptación, no se deducen del número de pruebas. |
| Cronograma | La línea base documental anterior proponía 26/10–09/11/2026. Las ejecuciones preliminares del 07–09/10 se mantienen con su fecha real; el calendario Jira debe reconciliarse antes de usarse como ejecución efectiva. |
| Costos | No consta un registro de horas ni desembolsos exclusivo de este sprint. El presupuesto global no se presenta como gasto ejecutado del sprint. |
| Calidad | Casos de aceptación y pruebas identificados en la Revisión del Sprint de esta carpeta. Los resultados históricos se conservan en [Evidencia técnica histórica](../evidencias/PRUEBAS_20261009.md); las revalidaciones posteriores se identifican por fecha y no son ceremonias históricas. |

## Cambios y mejoras

| Cambio | Resultado técnico documentado |
|---|---|
| Flota | Campos independientes, normalización de placa, validación, edición e inactivación. |
| Repartidores | Identidad, licencia, contacto, disponibilidad y origen diferenciados y vinculados a la cuenta. |
| Pedidos | Registro con destino y ventana, referencia, peso y lectura posterior. El registro no acredita optimización. |
| Formularios y contrato | Distribución adaptable, errores de campo y esquemas OpenAPI coherentes con el incremento. |

## Riesgos

| Riesgo | Responsable | Mitigación |
|---|---|---|
| Confundir un resultado técnico con aceptación del sprint | Jordy | Vincular escenario, versión, evidencia y decisión de revisión. |
| Usar IDs históricos como si fueran claves Jira actuales | Jordy | Aplicar [Reconciliación de alcance y códigos](../evidencias/RECONCILIACION_20261030.md) y conservar el prefijo LEG-20261009 en las referencias antiguas. |

## Próximos avances

Revalidar los escenarios de esta carpeta al cambiar el contrato; registrar la aceptación con su fecha real. Las funcionalidades de optimización, APK u otros sprints no se declaran completadas en este informe.

## Notas

La versión anterior permanece en Histórico y en el commit 66f25c8. La corrección documental no cambia retrospectivamente el compromiso de Jira. Las observaciones de gestión y defectos no bloqueantes se separaron del registro de impedimentos.
