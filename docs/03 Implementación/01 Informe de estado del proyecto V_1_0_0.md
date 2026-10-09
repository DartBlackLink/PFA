[README principal](../../README.md) | [Siguiente](02%20Registro%20de%20Impedimentos%20V_1_0_0.md)

# Informe de estado del proyecto

**Nombre del proyecto:** EcoLogística Huancayo - DistriRápido S.A.C.  
**Líder del proyecto:** Jordy Steve Chancasanampa Torres. **Modalidad:** individual.  
**Fecha de elaboración:** 07/10/2026. **Versión documental:** 1.0.0.

Este documento define el plan de ejecución y evaluación de Sprint 1 y Sprint 2. Las fechas son propuestas para configurar Jira; los criterios y resultados esperados guían el trabajo. La guía de ajustes reúne las acciones y evidencias necesarias para acreditar su ejecución.

## Periodo del informe y control

| Sprint | Inicio propuesto | Fin propuesto | Goal | SP |
| --- | --- | --- | --- | --- |
| S1 | 12/10/2026 09:00 | 26/10/2026 09:00 | Base técnica y acceso seguro por rol con bloqueo progresivo | 22 |
| S2 | 26/10/2026 09:00 | 09/11/2026 09:00 | Flota y repartidores con datos válidos, UX y contrato API | 19 |

Zona America/Lima. Referencia de alcance: [Artefactos Jira](../02%20Planificaci%C3%B3n/02%20Artefactos%20Jira%20V_1_1_0.md); aceptación: [Backlog y DoD](../02%20Planificaci%C3%B3n/01%20Transformando%20a%20%C3%A1gil%20V_1_1_0.md). Actualizar el estado al final de cada sprint con resultados de casos y evidencias; calcular avance sobre SP comprometidos, sin tratar SP planificados como SP completados.

## Sprint 1

### Estado del proyecto

| Variables de control | Línea base y criterio de seguimiento |
| --- | --- |
| Alcance | US-001/002: 6 SP; EN-001-S1: 3, EN-002-S1: 5, EN-007-S1: 5 y EN-003-S1: 3. Total 22 SP. Incremento: clientes, API, migración, login por rol y RN-023 |
| Cronograma | Planning 12/10; revisión diaria de impedimentos; integración 19-22/10; validación 23/10; Review/retrospectiva al cierre 26/10. Avance=SP aceptados/22×100; registrar desviaciones y arrastres |
| Costos | Controlar horas reales y gastos con comprobante contra presupuesto del caso S/500,000 y estimación USD134,960. No convertir el presupuesto total en gasto S1; actualizar consumo de reserva por riesgo |
| Calidad | Login correcto/incorrecto/inactivo, rol, token vencido, logout, 5/10/300 s, persistencia y concurrencia; migración e integridad; DoD exige cobertura ≥80%, revisión por par y staging |

### Cambios y mejoras

| Cambio | Motivo | Resultado esperado |
| --- | --- | --- |
| RN-023 en API y clientes | Evitar intentos ilimitados y bloqueo evadible | Tercer fallo 5 s, cuarto 10 s, quinto/posteriores 300 s; contador y reinicio tras éxito |
| Estado de acceso compartido y sesión vigente | Mantener controles entre dispositivos/recargas | Bloqueo persistente, transición atómica, sesión validada por API |
| Estructura Web/móvil/API y migración explícita | Facilitar arranque e integridad reproducibles | Construcciones independientes y upgrade con CHECK/FK |
| Campos Jira y BDD alineados | Tener un único alcance evaluable | EHAPP, 22 SP y evidencia por US/enabler |

### Riesgos

| Riesgo | Responsable | Mitigación |
| --- | --- | --- |
| Bloqueo solo visual o perdido al recargar | Jordy | Persistencia servidor y casos S1-C04..08 |
| Capacidad individual y alcance desalineado | Jordy | Limitar WIP, registrar horas y revisar los 22 SP en Planning |
| Acceso ajeno o integridad insuficiente | Jordy | Roles/propietario y migración con pruebas negativas |

### Próximos avances

Cerrar correcciones IMP-01..04, validar el incremento con los casos del Review y preparar los datos de flota/repartidores para S2. Mantener pendientes en backlog con causa y responsable, sin contabilizar dos veces el trabajo técnico compartido.

### Notas

RN-023 es una política de producto aplicable a ambos clientes: el reloj de la API decide el plazo y la pantalla solo lo representa. Datos de prueba sintéticos y credenciales sin exposición en capturas.

## Sprint 2

### Estado del proyecto

| Variables de control | Línea base y criterio de seguimiento |
| --- | --- |
| Alcance | US-003 y US-004: 5 SP cada una; EN-005-S2, EN-007-S2 y EN-009-S2: 3 SP cada una. Total 19 SP. Incremento: flota/repartidores, formularios accesibles y guía API |
| Cronograma | Planning 26/10; implementación 27/10-03/11; integración 04-05/11; validación 06/11; Review/retrospectiva 09/11. Avance=SP aceptados/19×100; separar arrastres de S1 |
| Costos | Registrar horas/gastos S2 por actividad y sumar al acumulado, sin duplicar gasto anterior. Aprobar uso de reserva únicamente con riesgo, importe y saldo |
| Calidad | CRUD/inactivación flota, datos conductor, duplicados, valores cero/negativos, permisos, lectura posterior, teclado/contraste y regresión RN-023 |

### Cambios y mejoras

| Cambio | Motivo | Resultado esperado |
| --- | --- | --- |
| Validación de flota en UI/API/BD | Evitar capacidades/consumo cero y placas duplicadas | Rechazo controlado y persistencia consistente |
| DNI/licencia/contacto/horario/origen separados | Evitar datos que no representan al conductor | Cada valor se guarda en su campo; disponibilidad y elegibilidad verificables |
| Formularios completos y accesibles | Reducir errores operativos | Etiquetas, foco, contraste, ayuda y mensajes por campo |
| Contrato API y manual sincronizados | Reproducir el uso y evitar endpoints ficticios | OpenAPI, payloads, errores y pasos conforme al incremento |

### Riesgos

| Riesgo | Responsable | Mitigación |
| --- | --- | --- |
| Datos incorrectos comprometen asignación | Jordy | Revisión formulario/DTO/modelo y lectura posterior S2-C03 |
| Accesibilidad o controles incompletos | Jordy | Checklist RNF-03 y regresión login/roles |
| Arrastres consumen capacidad S2 | Jordy | Replanificar sin doble conteo ni ocultar elementos incompletos |

### Próximos avances

Resolver IMP-05..07, ejecutar S2-C01..06 y cerrar EN-005/007/009-S2 con evidencia. Preparar S3: pedidos completos, coordenadas y preferencias CLIENTE; no iniciar optimización con datos incompletos.

### Notas

No mostrar métricas de demostración como resultados de operación. El registro de pruebas, demo, feedback y gasto real se incorpora al ejecutar el plan mediante el procedimiento de la guía.

## Historial de control de cambios

| Versión | Fecha | Responsable | Cambio |
| --- | --- | --- | --- |
| 1.0.0 | 07/10/2026 | Jordy Steve Chancasanampa Torres | Elaboración y refinamiento de la línea base S1/S2: fechas propuestas, entregables, criterios, mejoras y RN-023. |

[README principal](../../README.md) | [Siguiente](02%20Registro%20de%20Impedimentos%20V_1_0_0.md)
