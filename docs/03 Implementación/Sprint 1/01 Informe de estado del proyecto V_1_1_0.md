[Índice de implementación](../README.md) · [README del proyecto](../../../README.md)

# Informe de estado — Sprint 1

**Proyecto:** EcoLogística Huancayo — caso DistriRápido S.A.C.

**Responsable:** Jordy Steve Chancasanampa Torres. **Sprint:** 1. **Versión:** 1.1.0. **Revisión correctiva:** 30/10/2026.

**Periodo del informe técnico:** 07–09/10/2026, fechas de las evidencias originales asociadas a este sprint. Esta revisión separa el informe combinado; no inventa ceremonias ni aceptación docente posterior.

## Estado del proyecto

| Variable de control | Estado exclusivo de este sprint |
|---|---|
| Alcance | Acceso, sesión y autorización API/Web. Se informa capacidad técnica y su evidencia; los SP aceptados requieren decisión de aceptación, no se deducen del número de pruebas. |
| Cronograma | La línea base documental anterior proponía 12–26/10/2026. Las ejecuciones preliminares del 07–09/10 se mantienen con su fecha real; el calendario Jira debe reconciliarse antes de usarse como ejecución efectiva. |
| Costos | No consta un registro de horas ni desembolsos exclusivo de este sprint. El presupuesto global no se presenta como gasto ejecutado del sprint. |
| Calidad | Casos de aceptación y pruebas identificados en la Revisión del Sprint de esta carpeta. Los resultados históricos se conservan en [Evidencia técnica histórica](../evidencias/PRUEBAS_20261009.md); las revalidaciones posteriores se identifican por fecha y no son ceremonias históricas. |

## Cambios y mejoras

| Cambio | Resultado técnico documentado |
|---|---|
| Identidad y sesión | Login por rol, restauración mediante /auth/me, expiración y cuenta activa. |
| Autorización | La API verifica rol y propiedad de los recursos; ocultar botones no sustituye este control. |
| Bloqueo progresivo | Contador persistente, bloqueo de fila y esperas 5/10/300 segundos; contador visible en Web. |
| Migraciones | La conexión de Alembic usa la configuración del entorno y las pruebas emplean una BD aislada. |

## Riesgos

| Riesgo | Responsable | Mitigación |
|---|---|---|
| Confundir un resultado técnico con aceptación del sprint | Jordy | Vincular escenario, versión, evidencia y decisión de revisión. |
| Usar IDs históricos como si fueran claves Jira actuales | Jordy | Aplicar [Reconciliación de alcance y códigos](../evidencias/RECONCILIACION_20261030.md) y conservar el prefijo LEG-20261009 en las referencias antiguas. |

## Próximos avances

Revalidar los escenarios de esta carpeta al cambiar el contrato; registrar la aceptación con su fecha real. Las funcionalidades de optimización, APK u otros sprints no se declaran completadas en este informe.

## Notas

La versión anterior permanece en Histórico y en el commit 66f25c8. La corrección documental no cambia retrospectivamente el compromiso de Jira. Las observaciones de gestión y defectos no bloqueantes se separaron del registro de impedimentos.
