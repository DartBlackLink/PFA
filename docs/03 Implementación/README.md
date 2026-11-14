# Implementación por sprint

Los informes de estado corresponden a un único sprint. Cada carpeta conserva sus cuatro entregables independientes; la entrega combinada anterior permanece en Histórico y en el historial de Git.

| Sprint | Documentos | Estado documental |
|---|---|---|
| Sprint 1 | [Estado](Sprint%201/01%20Informe%20de%20estado%20del%20proyecto%20V_1_1_0.md) · [Impedimentos](Sprint%201/02%20Registro%20de%20Impedimentos%20V_1_1_0.md) · [Revisión](Sprint%201/03%20Revisi%C3%B3n%20del%20Sprint%20V_1_1_0.md) · [Retrospectiva](Sprint%201/04%20Retrospectiva%20del%20Sprint%20V_1_1_0.md) | Corrección 1.1.0 del 30/10/2026; aceptación histórica diferenciada de pruebas técnicas. |
| Sprint 2 | [Estado](Sprint%202/01%20Informe%20de%20estado%20del%20proyecto%20V_1_1_0.md) · [Impedimentos](Sprint%202/02%20Registro%20de%20Impedimentos%20V_1_1_0.md) · [Revisión](Sprint%202/03%20Revisi%C3%B3n%20del%20Sprint%20V_1_1_0.md) · [Retrospectiva](Sprint%202/04%20Retrospectiva%20del%20Sprint%20V_1_1_0.md) | Corrección 1.1.0 del 30/10/2026; aceptación histórica diferenciada de pruebas técnicas. |
| Sprint 3 | [Estado](Sprint%203/01%20Informe%20de%20estado%20del%20proyecto%20V_1_0_0.md) · [Impedimentos](Sprint%203/02%20Registro%20de%20Impedimentos%20V_1_0_0.md) · [Revisión](Sprint%203/03%20Revisi%C3%B3n%20del%20Sprint%20V_1_0_0.md) · [Retrospectiva](Sprint%203/04%20Retrospectiva%20del%20Sprint%20V_1_0_0.md) | Incremento GA verificado; compromiso Jira y aceptación diferenciados. |
| Sprint 4 | [Estado](Sprint%204/01%20Informe%20de%20estado%20del%20proyecto%20V_1_0_0.md) · [Impedimentos](Sprint%204/02%20Registro%20de%20Impedimentos%20V_1_0_0.md) · [Revisión](Sprint%204/03%20Revisi%C3%B3n%20del%20Sprint%20V_1_0_0.md) · [Retrospectiva](Sprint%204/04%20Retrospectiva%20del%20Sprint%20V_1_0_0.md) · [Índice y anexos](Sprint%204/README.md) | Preparación histórica del 13/11 y actualización técnica del 14/11: mapa, indicadores y muestra integrada de rendimiento; calendario/aceptación Jira por confirmar. |

[Resultados históricos del 30/10](evidencias/20261030/RESULTADOS.md) · [matriz académica](evidencias/20261030/MATRIZ_DE_CUMPLIMIENTO.md) · [inspección UI](evidencias/20261030/INSPECCION_UI.md) · [acciones externas](evidencias/20261030/ACCIONES_EXTERNAS.md).

Informes Green IT de semana 13, **revisados el 13/11/2026 (contenido 1.2.1)** y vinculados al Sprint 4: [impacto ambiental](reduccion%20del%20impacto%20ambiental/01%20Informe%20de%20reduccion%20del%20impacto%20ambiental%20V_1_0_0.md) y [estándares](reduccion%20del%20impacto%20ambiental/02%20Estandares%20Ingenier%C3%ADa%20de%20software%20V_1_0_0.md).

- [Reconciliación de IDs, alcance e impedimentos](evidencias/RECONCILIACION_20261030.md).
- [Entrega histórica combinada](Hist%C3%B3rico/Entrega%2020261009/README.md).
- [README del proyecto](../../README.md).

## Evidencia seleccionada

| Sprint | Alcance y evidencia |
| --- | --- |
| 1 | Autenticación y control de acceso en la [revisión del Sprint 1](Sprint%201/03%20Revisi%C3%B3n%20del%20Sprint%20V_1_1_0.md) y la [verificación técnica histórica](evidencias/VERIFICACION_TECNICA.md). |
| 2 | Recursos, pedidos, asignación y mapa en la [revisión del Sprint 2](Sprint%202/03%20Revisi%C3%B3n%20del%20Sprint%20V_1_1_0.md) y la [revalidación histórica](evidencias/PRUEBAS_20261009.md). |
| 3 | Optimización genética (EHAPP-13 / US-005) en el [corte del 30/10](evidencias/20261030/RESULTADOS.md). [Verificación de CRUD y permisos](evidencias/20261108-verificacion-integral/RESULTADOS.md), [mapa de Huancayo, congestión, aprobación, acuse Android y persistencia](evidencias/20261109-validacion-danleo/CIERRE_DANLEO_20261109.md), [cobertura backend](evidencias/20261103-estabilizacion/COBERTURA.md) y [análisis SonarQube del 04/11](evidencias/20261104-cierre/SONARQUBE_ACTUAL.md). |

Los cortes conservan sus resultados y fechas. Los HTML generados y registros brutos excluidos de Git permanecen en la copia local de auditoría. Cada revisión distingue las verificaciones técnicas de la aceptación académica.


## Actualización web — 14/11/2026

La web incorpora reportes PDF, indicadores, clientes/preferencias y equivalencia con fuente. Se corrigieron la asignación manual, los horarios y el contrato de indicadores; se preservaron los datos y se verificó el ciclo ADMIN → REPARTIDOR → ADMIN → REPARTIDOR por botones.

Regresión compartida: 141 pruebas backend, 93 pruebas Flutter; cobertura backend: 90.03135%. No es un análisis Sonar nuevo ni significa que todos los sprints estén aceptados. Los resultados anteriores de este README son cortes históricos.

- [Distribución de sprints 1–6](PLAN_FINAL_SPRINTS_WEB.md).
- [Matriz de aceptación de 12 US y 5 EN](MATRIZ_FINAL_BACKLOG_WEB.md).
- [Sprint 4 actualizado](Sprint%204/README.md), [Sprint 5](Sprint%205/README.md), [Sprint 6](Sprint%206/README.md).
- [Resultados/evidencias](evidencias/20261114-desarrollo-integral/RESULTADOS.md) y [acciones externas](ACCIONES_EXTERNAS_Y_CIERRE_WEB.md).

La aplicación activa se ejecuta en D:/UC/App/ecologistica, web http://127.0.0.1:8080. PFA contiene las fuentes y la documentación de entrega; no crea otra base operativa ni incluye credenciales. Consulte INICIAR_WEB.ps1 y OPERACION_LOCAL.md para el arranque configurado.
