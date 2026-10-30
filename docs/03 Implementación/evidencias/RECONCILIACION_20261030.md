# Reconciliación documental y de alcance — 30/10/2026

## Fuentes y estados

VERIFICADO: entrega local en commit 66f25c8; cuatro archivos combinaban S1/S2. PFA coincide con origin/main al iniciar. La app activa contiene mejoras del 23/10 no copiadas a PFA; se compararon 54 fuentes de aplicación y difieren 31.

REPORTADO: el contexto actualizado del usuario identifica EHAPP-10/US-002 flota S2; EHAPP-12/US-004 pedidos S2; EHAPP-13/US-005 optimización genética S3, 13 SP; EHAPP-15/US-006 mapa y EN-002/EN-003/EN-005 sin sprint confirmado. La lectura autenticada actual de Jira requiere completarse; no se alteró el tablero.

## Correspondencias y discrepancias

| Fuente anterior | Fuente actual reportada | Diferencia / impacto | Resolución |
|---|---|---|---|
| LEG-20261009/US-003: flota | EHAPP-10 / US-002: flota | Identificador distinto para la misma capacidad | Conservar alias histórico y usar la clave EHAPP estable al confirmar Jira. |
| LEG-20261009/US-004: repartidores | US-004 corresponde a pedidos en EHAPP-12 | Colisión de códigos | El ID histórico se cita con prefijo; la clave de repartidores requiere lectura de Jira. |
| LEG-20261009/US-005: pedidos | EHAPP-13 / US-005: optimización genética | Cambia el significado y el objetivo de S3 | No contar pedidos ni APK como optimización; implementar un motor genético separado. |
| S3 propuesto de 22 SP y APK | S3 reportado EHAPP-13, 13 SP | Compromiso incompatible | La propuesta de 22 SP queda histórica; fechas, total y dependencias requieren confirmación actual. |
| US-007 optimización en V1.2.0 | US-005 / EHAPP-13 actual | El requisito RF-03 permanece estable | RF-03 es el vínculo técnico; no renumerar silenciosamente el backlog histórico. |

## Reclasificación del registro combinado

| IDs anteriores | Clasificación correcta | Tratamiento |
|---|---|---|
| IMP-01 y ajuste de alcance | Inconsistencia documental / gestión | Corregir trazabilidad y retrospectiva; no hay actividad detenida acreditada. |
| IMP-02 | Tarea de organización de repositorio | Gestionar estructura/exclusiones, fuera del registro de impedimentos. |
| IMP-03 | Riesgo de configuración sin evidencia de bloqueo fechado | Mitigar con configuración y prueba aislada; no declarar un incidente real. |
| IMP-04 | Requisito y tareas de seguridad | Verificar con pruebas, no tratarlo como impedimento. |
| IMP-05 y IMP-06 | Defectos de validación y correspondencia de datos | Corregir y revalidar; solo serían impedimentos si bloquearan trabajo acreditado. |
| IMP-07-A | Defecto de usabilidad | Conservar evidencia de corrección y evaluación. |
| IMP-07-B e IMP-08 | Actividades de aceptación / revisión | Gestionar mediante checklist y compromisos, no como obstáculos ocurridos. |

## Preservación y criterio de aceptación

La entrega original se conserva en Histórico/Entrega 20261009 y en Git. Solo se repararon sus enlaces relativos al trasladarla. La versión correctiva 1.1.0 tiene cuatro documentos por sprint y no altera retrospectivamente resultados o ceremonias. Las pruebas nuevas se fecharán en el incremento que las ejecute; no convierten automáticamente SP en aceptados.
