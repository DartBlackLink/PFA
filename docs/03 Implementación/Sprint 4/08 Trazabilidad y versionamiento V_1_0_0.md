# Trazabilidad y versionamiento — Sprint 4

**Proyecto:** EcoLogística Huancayo. **Responsable:** Jordy Steve Chancasanampa Torres. **Versión:** 1.0.0. **Fecha:** 13/11/2026.

## Línea base de este expediente

Fuente vigente de identificadores: consulta autenticada de Jira del 13/11/2026. El usuario aceptó la propuesta documental de mapa + dashboard + rendimiento. La asignación a un Sprint 4, su calendario y su aceptación no se han creado mediante esta tarea.

| Jira / ID actual | RF o RNF | Propósito | Criterios preparados | Evidencia de cierre prevista |
|---|---|---|---|---|
| EHAPP-15 / US-006 | RF-04 | Representar recorrido y paradas sin inventar ubicación. | S4-MAP-GOLD/FELIZ/INFELIZ/BORDE | Capturas propias, lista, geometría/versión, permisos y resultados. |
| EHAPP-16 / US-007 | RF-05 | Indicadores de una planificación identificada. | S4-DASH-GOLD/FELIZ/INFELIZ/BORDE | Valores de origen, cálculo independiente y estados de ausencia. |
| EHAPP-14 / EN-002 | RNF-01 | Medición integrada de optimización y reoptimización. | S4-PERF-GOLD/FELIZ/INFELIZ/BORDE | Dataset, semillas, entorno, tiempos crudos y factibilidad. |
| Controles transversales | RNF-02/03/07 | Seguridad, accesibilidad y documentación. | DoD de la Revisión y anexos 05–07 | Análisis y revisión manual de la versión candidata. |

Los casos completos están en la [Revisión](03%20Revisi%C3%B3n%20del%20Sprint%20V_1_0_0.md). RF/RNF mantienen su significado en los documentos de Inicio; sus alias US/EN anteriores se reconcilian por clave, nombre y funcionalidad.

## Discrepancias históricas conservadas

| Referencia | Diferencia | Tratamiento |
|---|---|---|
| LEG-V1.2: S4 con US-007/13 SP y EN-004-S4/EN-003-S4, total 21 SP, 23/11–07/12 | Ese calendario y esos números no coinciden con Jira actual. | Conservar el documento como histórico. Este S4 propone 15 SP y no importa esas fechas como oficiales. |
| LEG-V1.2 US-006 | Clientes y preferencias, no mapa. | En este expediente US-006 siempre aparece junto a EHAPP-15 y su nombre actual. |
| LEG-V1.2 EN-002 / EN-004 | BD y benchmark respectivamente; Jira usa EN-002 para rendimiento. | Usar EHAPP-14/EN-002 y RNF-01. No presentar migraciones como entrega de rendimiento. |
| EHAPP-13/US-005 | Generación genética registrada en S3. | Dependencia heredada, no nueva entrega ni SP duplicados de S4. |
| Ejemplo ECL | Otro equipo, backlog, tecnologías y resultados. | Referencia de organización. No crear tickets ECL ni copiar porcentajes o actas. |

[Reconciliación anterior](../evidencias/20261104-cierre/ALCANCE_Y_RECONCILIACION.md) · [Consulta propia actual](evidencias/consulta-jira-20261113.json).

## Versionamiento documental

Los cuatro entregables conservan sus nombres oficiales. Los anexos se numeran después para mantener la estructura del proyecto. La versión 1.0.0 describe este corte preparatorio y no significa release del software. Una corrección de redacción/enlace incrementará parche; cambios de alcance o resultados deben registrar nueva versión, fecha, motivo y evidencia.

Al completar un documento, actualizar su tabla de cambios; no reemplazar una medición histórica por una actual sin conservar el corte. No se harán commits ni push en este encargo. Las consignas originales se preservan aunque mencionen Lima; la implementación y las nuevas evidencias corresponden a Huancayo.

| Versión | Fecha | Responsable | Cambio |
|---|---|---|---|
| 1.0.0 | 13/11/2026 | Jordy Steve Chancasanampa Torres | Preparación documental S4 con propuesta aceptada de 15 SP, criterios y anexos propios; Jira y código sin modificaciones. |

## Fuentes

- [Proyecto propio y RF](../../01%20Inicio/06.%20Requisitos%20funcionales%20V_1_2_0.md) y [RNF](../../01%20Inicio/07.%20Requisitos%20no%20funcionales%20V_1_2_0.md).
- [Ejemplo de Sprint 04](https://github.com/JulioNaupariC/EcoLog-stica-Lima/tree/main/docs/03%20Implementaci%C3%B3n/Sprint%2004), árbol consultado `0f86a9d9e5ce2de227f4ff0d199797603660edeb`; se usa organización, no se importa contenido de su implementación.
- Plantillas comunes del profesor: Informe, Impedimentos, Revisión y Retrospectiva. No se altera su estructura ni se atribuye al ejemplo autoridad sobre el alcance propio.

[Índice del Sprint 4](README.md) · [Acciones de cierre](ACCIONES_PARA_CERRAR_SPRINT4.md)
