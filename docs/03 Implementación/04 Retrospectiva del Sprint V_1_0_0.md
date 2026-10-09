[README principal](../../README.md) | [Anterior](03%20Revisi%C3%B3n%20del%20Sprint%20V_1_0_0.md)

# Retrospectiva del Sprint

**Nombre del proyecto:** EcoLogística Huancayo - DistriRápido S.A.C.  
**Líder del proyecto:** Jordy Steve Chancasanampa Torres. **Modalidad:** individual.  
**Fecha de elaboración:** 07/10/2026. **Versión documental:** 1.0.0.

Este documento define el plan de ejecución y evaluación de Sprint 1 y Sprint 2. Las fechas son propuestas para configurar Jira; los criterios y resultados esperados guían el trabajo. La guía de ajustes reúne las acciones y evidencias necesarias para acreditar su ejecución.

## Enfoque de retrospectiva

Reflexión de diseño y plan de mejora derivado de la revisión del proyecto. En cada cierre, Jordy registra los aprendizajes observados al ejecutar el sprint y valida las acciones con sus resultados. Los ejes y acciones siguientes orientan la ceremonia; no se presentan como acuerdos de una reunión ya celebrada.

## Sprint 1

### ¿Qué aprendimos?

Login, autorización y sesión son controles distintos. RN-023 necesita estado de servidor: un contador solo visual permitiría evadirlo al recargar. La secuencia 5 s/10 s/5 min requiere pruebas de límites, persistencia y concurrencia, además del login correcto.

### ¿Qué estamos haciendo bien?

El proyecto tiene requisitos por rol, criterios BDD y base de API/Flutter sobre la que construir. Separar US-001/002 del enabler de seguridad permite una política compartida sin duplicar esfuerzos ni SP. La línea base usa un proyecto Jira, un calendario y objetivos verificables.

### ¿Qué podemos hacer mejor?

#### Personas

Jordy cubre análisis/desarrollo/QA: reservar tiempo de verificación distinto del tiempo de programación y limitar trabajo en curso. Preparar revisión por par o adaptación docente para el DoD; medir capacidad en horas antes del compromiso.

#### Relaciones

Presentar la adaptación Flutter/individual al docente y acordar la revisión del incremento. Separar escenarios ficticios de participantes reales; registrar feedback recibido con decisión y actividad asociada.

#### Procesos

Cerrar criterios antes de Done; probar el tercer, cuarto y quinto fallo con reloj del servidor. Mantener el alcance S1 de 22 SP y mover incompletos con causa; conservar fechas/evidencias históricas fuera del nuevo plan.

#### Herramientas

Usar EHAPP con BDD, componentes y Fix Version; PostgreSQL para control de acceso atómico; Flutter para contador visible. Reemplazar la prueba de existencia de clase por casos de login/roles y registrar comandos/resultados.

### Acciones a realizar

| Acción | Responsable | Fecha objetivo | Criterio de éxito |
| --- | --- | --- | --- |
| A-S1-01: alinear EHAPP y 22 SP; IMP-01 | Jordy | 12/10/2026 | Goal, periodo, elementos y campos correctos |
| A-S1-02: clientes, migración y entorno; IMP-02/03 | Jordy | 20/10/2026 | Arranque limpio y upgrade con integridad |
| A-S1-03: RN-023, sesión y permisos; IMP-04 | Jordy | 23/10/2026 | S1-C02..08 aprobados y contador persistente |
| A-S1-04: DoD y expediente Review; IMP-08 | Jordy | 26/10/2026 | Pruebas, revisión, demo y feedback asociados a versión |

## Sprint 2

### ¿Qué aprendimos?

Un alta aparentemente exitosa puede guardar datos en columnas equivocadas. Comparar formulario, DTO, modelo y lectura posterior detecta placa/licencia y horario/contacto. RN-023 debe permanecer intacta al añadir módulos y modificar la navegación.

### ¿Qué estamos haciendo bien?

RF-01/RF-08 tienen historias y casos separados. El plan conecta validación de flota/conductor con accesibilidad, UX y contrato API; así cada mejora tiene un resultado visible y verificable.

### ¿Qué podemos hacer mejor?

#### Personas

Priorizar integridad de datos antes de ampliar mapas/KPIs. Reservar una revisión de campos y una prueba de lectura por cada alta/edición; revisar arrastres S1 antes de comprometer S2.

#### Relaciones

Mostrar al revisor un recorrido de administrador y repartidor con datos sintéticos coherentes. Transformar feedback de formularios en acciones de UX con responsable, sin confundir opinión hipotética con validación realizada.

#### Procesos

Probar válido, inválido, duplicado, inactivación y permisos. No cerrar CRUD completo por tener solo alta/listado. Mantener los 19 SP separados de arrastres y registrar decisiones antes de iniciar pedidos S3.

#### Herramientas

Mantener mockups y nombres de campos iguales al contrato; usar OpenAPI/manual para probar el flujo. Verificar teclado/contraste y regresión del contador de login; guardar evidencias reales del mismo proyecto Jira.

### Acciones a realizar

| Acción | Responsable | Fecha objetivo | Criterio de éxito |
| --- | --- | --- | --- |
| A-S2-01: validar flota; IMP-05 | Jordy | 30/10/2026 | S2-C01/02 aprobados sin duplicados/valores cero |
| A-S2-02: corregir conductor; IMP-06 | Jordy | 03/11/2026 | S2-C03/04 aprobados con campos separados |
| A-S2-03: UX, accesibilidad y contrato; IMP-07 | Jordy | 06/11/2026 | S2-C05/06 evaluados, API/documentación concordantes |
| A-S2-04: Review/DoD y backlog S3; IMP-08 | Jordy | 09/11/2026 | Expediente real y decisiones sin doble conteo |

## Seguimiento de cambios y mejoras

En S2 revisar A-S1-01..04: registrar resultado, mantener las abiertas con causa o cerrar con evidencia. Cada acción tiene una condición verificable; cambiar texto o estado de Jira no sustituye esa condición. Comparar defectos, tiempos de corrección y dificultades de uso entre ambos sprints cuando se ejecute el plan.

## Historial de control de cambios

| Versión | Fecha | Responsable | Cambio |
| --- | --- | --- | --- |
| 1.0.0 | 07/10/2026 | Jordy Steve Chancasanampa Torres | Elaboración y refinamiento de la línea base S1/S2: fechas propuestas, entregables, criterios, mejoras y RN-023. |

[README principal](../../README.md) | [Anterior](03%20Revisi%C3%B3n%20del%20Sprint%20V_1_0_0.md)
