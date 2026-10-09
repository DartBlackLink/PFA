[⌂ README principal](../../README.md) | [← Anterior](01%20Transformando%20a%20%C3%A1gil%20V_1_2_0.md) | [Siguiente →](03%20Registro%20de%20riesgos%20V_1_2_0.md)

# Artefactos Jira

| Campo | Valor |
| --- | --- |
| Proyecto | EcoLogística Huancayo - DistriRápido S.A.C. |
| Responsable | Jordy Steve Chancasanampa Torres |
| Modalidad | Individual; responsabilidades Scrum adaptadas |
| Fecha de revisión | 09/10/2026 |
| Versión documental | 1.2.0 |
| Estado | Especificación y plan de trabajo; validación según criterios de aceptación |

## Identidad del proyecto y estado de evidencia

Proyecto a configurar: **EcoLogística Huancayo**, clave **EHAPP**. Usar IDs canónicos US-001..US-014, EN-001..EN-009 y EP-01..EP-07 en el resumen/descripción; las claves EHAPP asignadas por Jira se conservan. Una porción EN-XXX-Sn es una tarea ejecutable con SP propios, no una duplicación del total agregado del enabler. La correspondencia de IDs se mantiene en los campos de trazabilidad de cada actividad.

## Configuración objetivo

Jerarquía Epic → Story/Task → Sub-task; Bug separado. Cada issue ejecutable incluye título, Como/Quiero/Para o objetivo técnico, dos BDD, prioridad, SP, RF/RNF, componente, sprint, dependencia, responsable y Fix Version v1.0.0-MVP. Componentes: web, mobile, backend-api, database, optimization, security, qa, figma y documentation. El código de versión del producto es independiente de la versión documental 1.2.0.

```mermaid
flowchart LR
    A[To Do] --> B[In Progress]
    B --> C[In Review / QA]
    C --> D[Done]
    C --> B
```

## Product Backlog y estimaciones

| ID | Historia | Épica | SP | RF/RNF | Sprint objetivo |
| --- | --- | --- | --- | --- | --- |
| US-001 | Autenticación administrador | EP-01 | 3 | Transversal / RNF-02 | S1 |
| US-002 | Autenticación repartidor móvil | EP-01 | 3 | Transversal / RNF-02 | S3 |
| US-003 | Gestionar flota | EP-02 | 5 | RF-01 | S2 |
| US-004 | Gestionar repartidores | EP-02 | 5 | RF-08 | S2 |
| US-005 | Gestionar pedidos | EP-03 | 8 | RF-02 | S3 |
| US-006 | Clientes y preferencias | EP-03 | 5 | RF-09 | S3 |
| US-007 | Generar rutas optimizadas | EP-04 | 13 | RF-03 | S4 |
| US-008 | Visualizar mapa global | EP-05 | 8 | RF-04 | S5 |
| US-009 | Consultar mi ruta | EP-05 | 8 | RF-04 | S5 |
| US-010 | Entrega e incidente | EP-05 | 5 | RF-07 | S5 |
| US-011 | Reoptimizar rutas | EP-04 | 8 | RF-07 | S6 |
| US-012 | Consultar dashboard | EP-06 | 5 | RF-05 | S6 |
| US-013 | Generar reporte PDF | EP-06 | 5 | RF-06 | S6 |
| US-014 | Plan de compensación | EP-06 | 5 | RF-10 | S7 |

## Replanificación acordada — 09/10/2026

US-002 pasa de S1 a S3 por decisión del responsable. Alcance vigente: **S1 19 SP, S2 19 SP, S3 22 SP**. El total del proyecto no cambia. La API compartida de identidad y seguridad permanece en S1; la aceptación móvil se demuestra en S3. Actualizar la misma issue en Jira conservando su clave, BDD e historial; no duplicarla ni marcar APK completada con una prueba Web.

## Roadmap y Sprint Backlog objetivo

Calendario propuesto para configurar Jira: inicio 12/10/2026, fin 18/01/2027, siete sprints consecutivos de dos semanas. Crear cada sprint con el mismo objetivo, alcance y SP que las tablas siguientes. Hora de inicio/cierre 09:00 America/Lima; el cierre es frontera exclusiva del periodo, sin solapamientos. Este calendario es una propuesta de ejecución, no un historial de trabajo completado.

**Cierre:** aceptar únicamente elementos con BDD/DoD cumplidos; arrastrar incompletos con causa y evidencias, sin duplicar SP.

### Sprint 1 - 12/10/2026 a 26/10/2026

**Sprint Goal:** Base técnica, acceso por rol y bloqueo progresivo 5 s / 10 s / 5 min. **Estado de configuración:** To Do; criterios de cierre aplicables a cada elemento.

| Issue/porción | SP |
| --- | --- |
| US-001 | 3 |
| EN-001-S1 | 3 |
| EN-002-S1 | 5 |
| EN-007-S1 | 5 |
| EN-003-S1 | 3 |
| Total | 19 |

**Incremento esperado:** Cliente Web ejecutable, base de fuentes móviles, API, migración, login por rol y RN-023 con contador persistente y diseño inicial.

**Demo y aceptación:** Arranque limpio, login válido/inválido, permisos y fallos 3/4/5 con esperas 5/10/300 s; recarga y reinicio tras éxito.

### Sprint 2 - 26/10/2026 a 09/11/2026

**Sprint Goal:** Flota y repartidores. **Estado de configuración:** To Do; criterios de cierre aplicables a cada elemento.

| Issue/porción | SP |
| --- | --- |
| US-003 | 5 |
| US-004 | 5 |
| EN-005-S2 | 3 |
| EN-007-S2 | 3 |
| EN-009-S2 | 3 |
| Total | 19 |

**Incremento esperado:** Gestión válida de vehículos y repartidores, perfil propio.

**Demo y aceptación:** Crear/editar/inactivar vehículo; registrar conductor con campos correctos y probar restricciones.

### Sprint 3 - 09/11/2026 a 23/11/2026

**Sprint Goal:** Pedidos, clientes, preferencias y aceptación del acceso móvil. **Estado de configuración:** To Do; criterios de cierre aplicables a cada elemento.

| Issue/porción | SP |
| --- | --- |
| US-002 | 3 |
| US-005 | 8 |
| US-006 | 5 |
| EN-003-S3 | 3 |
| EN-009-S3 | 3 |
| Total | 22 |

**Incremento esperado:** Pedidos completos, georreferenciación, preferencias propias/asistidas y APK con acceso REPARTIDOR probado.

**Demo y aceptación:** Demostrar ventanas, ubicación confirmada y aislamiento de clientes; en Android comprobar login, logout, sesión, permisos y contador 5/10/300 s.

### Sprint 4 - 23/11/2026 a 07/12/2026

**Sprint Goal:** Algoritmo genético VRPTW/Green VRP. **Estado de configuración:** To Do; criterios de cierre aplicables a cada elemento.

| Issue/porción | SP |
| --- | --- |
| US-007 | 13 |
| EN-004-S4 | 5 |
| EN-003-S4 | 3 |
| Total | 21 |

**Incremento esperado:** Plan factible persistido con métricas y benchmark.

**Demo y aceptación:** Ejecutar dataset 150/15; mostrar semilla, límites, tiempos y línea base.

### Sprint 5 - 07/12/2026 a 21/12/2026

**Sprint Goal:** Mapa y operación móvil. **Estado de configuración:** To Do; criterios de cierre aplicables a cada elemento.

| Issue/porción | SP |
| --- | --- |
| US-008 | 8 |
| US-009 | 8 |
| US-010 | 5 |
| EN-008-S5 | 3 |
| Total | 24 |

**Incremento esperado:** Mapa global, ruta propia, entrega e incidente y caché inicial.

**Demo y aceptación:** Consultar dos identidades, registrar entrega/incidente y desconectar móvil.

### Sprint 6 - 21/12/2026 a 04/01/2027

**Sprint Goal:** Reoptimización e indicadores. **Estado de configuración:** To Do; criterios de cierre aplicables a cada elemento.

| Issue/porción | SP |
| --- | --- |
| US-011 | 8 |
| US-012 | 5 |
| US-013 | 5 |
| EN-006-S6 | 3 |
| EN-004-S6 | 3 |
| Total | 24 |

**Incremento esperado:** Evento, nuevo plan, métricas y PDF reconciliados.

**Demo y aceptación:** Simular cancelación/avería, preservar completadas, medir <30 s y descargar PDF.

### Sprint 7 - 04/01/2027 a 18/01/2027

**Sprint Goal:** Compensación, calidad y release. **Estado de configuración:** To Do; criterios de cierre aplicables a cada elemento.

| Issue/porción | SP |
| --- | --- |
| US-014 | 5 |
| EN-003-S7 | 3 |
| EN-005-S7 | 3 |
| EN-006-S7 | 3 |
| EN-008-S7 | 3 |
| EN-009-S7 | 3 |
| Total | 20 |

**Incremento esperado:** Release probado, manuales y propuesta de compensación.

**Demo y aceptación:** Mostrar aceptación RF-01..07, pruebas, cobertura, accesibilidad y pendientes complementarios.

## Auditoría de las cinco capturas conservadas

Las cinco capturas conservan su identidad y se relacionan con roadmap, backlog, planificación, tablero y release. La evidencia de cada corte debe corresponder al periodo y estados reales de Jira; se conserva su fecha y se contrasta con las tablas del backlog.

## Evidencias necesarias para cerrar Planificación y seguir con Implementación

| Elemento | Contenido requerido |
| --- | --- |
| Roadmap | EHAPP, siete sprints y calendario propuesto |
| Backlog | IDs canónicos, SP, epic, componentes y Fix Version |
| S1 / S2 Planning | Goal, fechas, 19/19 SP y alcance separado |
| Tablero | Mismo proyecto, sprint y estados según ejecución |
| Release | v1.0.0-MVP con issues asociados; publicar tras aceptación |
| Review y retrospectiva | Resultado de casos, demo, feedback y acciones enlazados |

Campos de login en US-001/US-002 y EN-003-S1: RN-023, BDD 5/10/300 s, backend-api/security/web/mobile/qa, prioridad High. S2 depende de la base S1. Subtareas de la misma historia no suman nuevamente SP del padre.

## Historial de control de cambios

| Versión | Fecha | Responsable | Cambio |
|---|---|---|---|
| 1.0.0 | 27/09/2026 | Jordy Steve Chancasanampa Torres | Versión previa del repositorio; conservada en historial Git y respaldo de revisión. |
| 1.1.0 | 07/10/2026 | Jordy Steve Chancasanampa Torres | Refinamiento documental: requisitos verificables, trazabilidad, decisiones y estado real de evidencias. Referencia actualizada a registros iniciales S1/S2. Calendario propuesto, RN-023 y guía de ajustes alineados. Sin modificación del software ni cierre de sprint. |
| 1.2.0 | 09/10/2026 | Jordy Steve Chancasanampa Torres | Coherencia con el incremento comprobado, navegación y expediente S1/S2. |

[⌂ README principal](../../README.md) | [← Anterior](01%20Transformando%20a%20%C3%A1gil%20V_1_2_0.md) | [Siguiente →](03%20Registro%20de%20riesgos%20V_1_2_0.md)
