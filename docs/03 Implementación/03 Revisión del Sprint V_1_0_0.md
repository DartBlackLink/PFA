[README principal](../../README.md) | [Anterior](02%20Registro%20de%20Impedimentos%20V_1_0_0.md) | [Siguiente](04%20Retrospectiva%20del%20Sprint%20V_1_0_0.md)

# Revisión del Sprint

**Nombre del proyecto:** EcoLogística Huancayo - DistriRápido S.A.C.  
**Líder del proyecto:** Jordy Steve Chancasanampa Torres. **Modalidad:** individual.  
**Fecha de elaboración:** 07/10/2026. **Versión documental:** 1.0.0.

Este documento define el plan de ejecución y evaluación de Sprint 1 y Sprint 2. Las fechas son propuestas para configurar Jira; los criterios y resultados esperados guían el trabajo. La guía de ajustes reúne las acciones y evidencias necesarias para acreditar su ejecución.

## Criterio de Review

La Review evalúa las historias y enablers siguientes mediante recorridos y resultados esperados. Marcar una historia como completada requiere BDD y [Backlog y DoD](../02%20Planificaci%C3%B3n/01%20Transformando%20a%20%C3%A1gil%20V_1_1_0.md); el listado representa el alcance a evaluar, no una declaración de Done. Responsable de demo: Jordy; interesados objetivo: docente/revisor y escenarios ADMIN/REPARTIDOR. Registrar asistentes y feedback reales en el cierre.

## Sprint 1

**Periodo propuesto:** 12/10/2026-26/10/2026. **Goal:** base técnica y acceso seguro con RN-023. **Review objetivo:** 26/10/2026, antes del cierre.

### Historias de Usuario completadas en este Sprint

| Elemento a evaluar | SP | Entregable y condición de aceptación |
| --- | --- | --- |
| US-001 | 3 | Login ADMIN Web, errores genéricos, logout y RN-023 con contador |
| US-002 | 3 | Login REPARTIDOR móvil, permisos del rol y misma política RN-023 |
| EN-001-S1 | 3 | Clientes/API reproducibles, configuración de ejemplo sin secretos |
| EN-002-S1 | 5 | Migración explícita, integridad y persistencia del estado de acceso |
| EN-007-S1 | 5 | Mockups por rol; estados de login, cuenta atrás, errores y bloqueo |
| EN-003-S1 | 3 | Sesión, autorización, actualización atómica y seguridad de la política compartida |
| Total | 22 | Aceptar solo elementos que cumplan todos sus criterios |

### Demostración del trabajo completado

| Caso | Recorrido de validación | Resultado esperado |
| --- | --- | --- |
| S1-C01 | Construir Web/móvil/API en entorno limpio; aplicar migración | Arranque independiente, health y esquema con CHECK/FK |
| S1-C02 | Login válido ADMIN/REPARTIDOR; inactivo/contraseña incorrecta; logout/token vencido | Acceso por rol, rechazo genérico y sesión finalizada/renovada correctamente |
| S1-C03 | Cruzar recursos con dos repartidores y probar administración desde móvil | Recurso propio permitido; ajeno y administración denegados |
| S1-C04 | Fallar 1, 2 y 3 veces con el mismo identificador | Primeros dos sin espera; tercero produce 429 y contador 5 s |
| S1-C05 | Tras vencer 5 s, fallar de nuevo; tras vencer 10 s, volver a fallar | Esperas exactas de 10 s y 300 s; botón bloqueado y contador mm:ss |
| S1-C06 | Reintentar durante espera, recargar, cambiar dispositivo/reiniciar API | Plazo preservado; petición no suma fallos ni extiende bloqueo |
| S1-C07 | Intentar credenciales correctas durante bloqueo y al vencer | Antes: 429; después: token válido, contador reiniciado; próximo fallo cuenta como primero |
| S1-C08 | Solicitudes simultáneas, cuenta inexistente y fallo de red | Estado atómico y respuesta genérica; no sumar fallos por red; API define el reloj |

RN-023 después del quinto fallo mantiene esperas de 300 s ante nuevos fallos hasta login correcto o recuperación validada. Medir fronteras justo antes/después del plazo; ninguna espera depende solo del navegador.

### Pendientes

Todo elemento que no pase un caso se devuelve a ejecución con defecto identificado, responsable y nueva prueba. Revisar IMP-01..04/08 y arrastrar solo con decisión de backlog. La guía concentra los resultados/evidencias por adjuntar y las diferencias actuales del prototipo.

## Sprint 2

**Periodo propuesto:** 26/10/2026-09/11/2026. **Goal:** flota/repartidores válidos, accesibles y documentados. **Review objetivo:** 09/11/2026, antes del cierre.

### Historias de Usuario completadas en este Sprint

| Elemento a evaluar | SP | Entregable y condición de aceptación |
| --- | --- | --- |
| US-003 | 5 | Alta/edición/inactivación flota; capacidad/consumo >0; placa única |
| US-004 | 5 | DNI/licencia/categoría/contacto/experiencia/disponibilidad/origen; perfil/eligibilidad correctos |
| EN-005-S2 | 3 | Teclado, foco, etiquetas, contraste y mensajes en formularios |
| EN-007-S2 | 3 | Campos y estados de UX concordantes con contratos; flujo sin datos y errores |
| EN-009-S2 | 3 | OpenAPI, payloads/errores y guía de flota/repartidores conformes al incremento |
| Total | 19 | Evaluar con DoD y mantener separados arrastres S1 |

### Demostración del trabajo completado

| Caso | Recorrido de validación | Resultado esperado |
| --- | --- | --- |
| S2-C01 | Crear, editar, consultar e inactivar vehículo | Lectura posterior conserva datos; vehículo inactivo no es elegible |
| S2-C02 | Placa duplicada, capacidad/consumo cero, valores negativos | Error controlado por campo; no duplicar ni dañar registros |
| S2-C03 | Registrar conductor con DNI/licencia/contacto/horario distintos y origen | Cada campo persistido en su lugar, identidad válida y horario elegible |
| S2-C04 | DNI duplicado, horario invertido, campos incompletos y cruce de perfil | Rechazo con causa y aislamiento; ningún DNI ficticio para alta real |
| S2-C05 | Teclado/lector, contraste, errores y vacío en formularios | Criterios RNF-03 evaluados y estados comprensibles; registrar hallazgos |
| S2-C06 | Regresión login/roles/RN-023 y recorrido de guía/OpenAPI | 5/10/300 s preservados; documentación coincide con API y permisos |

### Pendientes

Resolver defectos de S2-C01..06 e IMP-05..08 antes de aceptar el incremento. Revisar arrastres de S1 sin sumar sus SP como trabajo completado dos veces. Preparar contratos de pedido/preferencias S3 a partir de los datos maestros aceptados.

## Registro del resultado de la demo

Al ejecutar cada Review: registrar fecha/hora, versión de código, entorno, asistentes, caso, resultado obtenido, evidencia y feedback. Para cada observación decidir aceptar, corregir o crear actividad con responsable y hito. Una captura del tablero no sustituye el resultado del caso. La guía indica nombres de archivo y asociaciones Jira del expediente.

## Historial de control de cambios

| Versión | Fecha | Responsable | Cambio |
| --- | --- | --- | --- |
| 1.0.0 | 07/10/2026 | Jordy Steve Chancasanampa Torres | Elaboración y refinamiento de la línea base S1/S2: fechas propuestas, entregables, criterios, mejoras y RN-023. |

[README principal](../../README.md) | [Anterior](02%20Registro%20de%20Impedimentos%20V_1_0_0.md) | [Siguiente](04%20Retrospectiva%20del%20Sprint%20V_1_0_0.md)
