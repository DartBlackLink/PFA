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

Los casos completos están en la [Revisión](01%20Revisi%C3%B3n%20del%20Sprint%20V_1_0_0.md). RF/RNF mantienen su significado en los documentos de Inicio; sus alias US/EN anteriores se reconcilian por clave, nombre y funcionalidad.

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


## Actualización técnica — 14/11/2026

Este apartado posterior sustituye únicamente el carácter futuro de los controles que sí se ejecutaron: 141 pruebas backend, 93 Flutter, análisis Flutter sin incidencias, Bandit y auditoría de dependencias con sus informes finales. Cobertura backend: 90.0313479624 % (2872/3190, líneas + ramas); líneas 2321/2492, ramas 551/698. No es una calificación nueva de SonarQube.

Se ejecutaron generación/confirmación/incidencia/reoptimización/acuse/entregas por navegador y verificación posterior API/PostgreSQL. Se inspeccionaron pantallas y modal nuevos a 360 px en ambos temas. El PDF real se descargó, parseó y renderizó.

EN-002: endpoint 150/15 en 16,649722 s; replan de 3 pendientes en 1,780739 s. OSRM real; demanda sintética en tres puntos repetidos; una semilla 42, no cinco. No cubre renderizado ni una campaña representativa ni el peor caso. Se conserva el protocolo ampliado como acción, sin adjudicarlo como ejecutado.

La nueva migración 0008 agrega configuración ambiental opcional y auditada. Datos y cuentas existentes se preservaron. El hallazgo CVE-2026-126360 del lock se corrigió de 1.45.1 a 1.45.2; conserva auditoría antes/después.

Consulte [evidencias y resultados](../evidencias/20261114-desarrollo-integral/RESULTADOS.md) para resultados, comandos, versión y límites; [acciones externas](../ACCIONES_EXTERNAS_Y_CIERRE_WEB.md) centraliza lo que necesita intervención posterior.

[← Volver al README principal](../../../README.md)


## Ajuste documental de Semana 14 — 18/11/2026

La nueva consigna identifica Revisión/Retrospectiva como 01/02 y añade Playwright/Usabilidad como 03/04. Se renombraron solo esos dos documentos del Sprint 4 y se conservaron estado, impedimentos y anexos anteriores. La versión interna de cada texto registra el cambio aunque el nombre oficial conserve V_1_0_0. No se generan copias activas duplicadas ni se alteran los cortes históricos. El [control de Semana 14](CONTROL_SEMANA14.md) relaciona requisitos con evidencia y límites. Esta adenda sustituye únicamente las afirmaciones preparatorias que no correspondan al corte actual; no implica una ejecución de CI/CD ni aceptación.


## Seguimiento de evidencia — 18/11/2026

El corte anterior conserva sus resultados históricos. La validación posterior añade 145 backend, 30 E2E en tres motores y cinco semillas para cada tamaño 10/50/150. Se corrigieron consultas duplicadas y protocolo OSRM de una coordenada. Véanse [resultados, cobertura y límites](../evidencias/20261118-semana14/RESULTADOS.md). No se realizó un nuevo SonarQube, auditoría OWASP integral o certificación WCAG. Al corte local del 18/11 no había producción ni Actions. La [publicación manual del 19/11](../evidencias/20261119-despliegue-publico/RESULTADOS.md) incorpora URL, pruebas de roles y persistencia; no es una nueva auditoría integral o certificación. SUS humano y Actions siguen pendientes.
