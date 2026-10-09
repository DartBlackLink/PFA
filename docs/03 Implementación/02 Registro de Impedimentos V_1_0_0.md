[README principal](../../README.md) | [Anterior](01%20Informe%20de%20estado%20del%20proyecto%20V_1_0_0.md) | [Siguiente](03%20Revisi%C3%B3n%20del%20Sprint%20V_1_0_0.md)

# Registro de Impedimentos

**Nombre del proyecto:** EcoLogística Huancayo - DistriRápido S.A.C.

**Líder del proyecto:** Jordy Steve Chancasanampa Torres

**Modalidad:** individual. **Versión documental:** 1.0.0. **Revisión de entrega:** 09/10/2026.

**Periodo del informe técnico:** 07/10/2026-09/10/2026; ejecuciones técnicas registradas el 07 y el 09/10/2026.

El documento presenta el avance técnico asociado al alcance de Sprint 1 y Sprint 2. El calendario del backlog es una línea base propuesta; las fechas de prueba identifican la evidencia real y no se atribuyen a ceremonias Scrum. La versión 1.0.0 conserva la nomenclatura de la primera entrega exigida por ambas consignas.

## Criterio de seguimiento

Se registra el obstáculo observado, su efecto y la resolución verificable. Resuelto técnico significa corrección comprobada en el entorno indicado; la aceptación de la historia se evalúa por separado con su DoD. Los controles externos de entrega se gestionan en el documento local de acciones.

## Sprint 1

| Impedimento # | Fecha de Registro | Descripción del Impedimento así como el Impacto en el Proyecto | Prioridad | Reportado por | Fecha tope de Resolución | Estado | Fecha de Resolución | Resolución/Comentarios |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| IMP-01 | 07/10/2026 | Identificadores y alcance documental desalineados dificultaban relacionar requisitos, backlog y pruebas. | Alta | Jordy | 09/10/2026, corte documental | Resuelto documental | 09/10/2026 | RF/RNF, US/enablers y alcance S1/S2 relacionados; las claves reales de Jira se conservan y se vinculan con estos IDs. |
| IMP-02 | 07/10/2026 | Código mezclado con configuración/dependencias del equipo dificultaba preparar el repositorio. | Alta | Jordy | 07/10/2026, preparación de fuentes | Resuelto técnico | 07/10/2026 | Copias separadas apps/web, apps/mobile, backend y database; exclusión de temporales, credenciales y compilaciones. La compilación comprobada corresponde a Web. |
| IMP-03 | 07/10/2026 | Arranque y conexión de migraciones podían afectar una base distinta de la configurada. | Alta | Jordy | 07/10/2026, verificación técnica | Resuelto técnico | 07/10/2026 | Alembic toma DATABASE_URL de la configuración; migraciones explícitas y pruebas en base aislada. Esquema SQL vinculado a la misma cadena. |
| IMP-04 | 07/10/2026 | Bloqueo y sesión debían resistir recarga, concurrencia y acceso a recursos ajenos. | Alta | Jordy | 07/10/2026, verificación técnica | Resuelto técnico API/Web | 07/10/2026 | Estado persistente 5/10/300 s, /auth/me y consulta de rutas por propietario. Pruebas API 01-03/06 y pruebas de autenticación Flutter. |

## Sprint 2

| Impedimento # | Fecha de Registro | Descripción del Impedimento así como el Impacto en el Proyecto | Prioridad | Reportado por | Fecha tope de Resolución | Estado | Fecha de Resolución | Resolución/Comentarios |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| IMP-05 | 07/10/2026 | Capacidad/consumo cero y placas duplicadas comprometían los datos de flota. | Alta | Jordy | 07/10/2026, verificación técnica | Resuelto técnico | 07/10/2026 | Valores positivos, placa normalizada y rechazo 409/422; alta, edición e inactivación en prueba API 04. |
| IMP-06 | 07/10/2026 | La captura de conductor confundía placa/licencia y horario/contacto, afectando identificación y asignación. | Alta | Jordy | 07/10/2026, verificación técnica | Resuelto para nuevas altas | 07/10/2026 | Formulario/DTO/modelo con campos independientes; duplicados, horario inválido, lectura e inactivación en prueba API 05. Los registros históricos se conservan para revisión individual. |
| IMP-07-A | 07/10/2026 | Distribución y estados de formularios dificultaban operar la interfaz a distintos tamaños. | Media | Jordy | 07/10/2026, verificación técnica | Resuelto en distribución verificada | 07/10/2026 | Distribución adaptable, foco y botones; cuatro tamaños probados y guía API sincronizada. La evaluación WCAG completa es un control distinto. |

## Control transversal de aceptación

| Impedimento # | Fecha de Registro | Descripción del Impedimento así como el Impacto en el Proyecto | Prioridad | Reportado por | Fecha tope de Resolución | Estado | Fecha de Resolución | Resolución/Comentarios |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| IMP-07-B | 09/10/2026 | La aceptación de accesibilidad requiere evaluación de teclado, lector y contraste, además de distribución. | Media | Jordy | Cierre S2 de la línea base: 09/11/2026 | En validación | Al aprobar el checklist | Aplicar criterios RNF-03, guardar resultados por pantalla y relacionarlos con EN-005-S2. |
| IMP-08 | 07/10/2026 | La aceptación académica debe relacionar pruebas, versión, revisión y demostración. | Alta | Jordy | Cierres de línea base S1 26/10 y S2 09/11/2026 | En validación | Al registrar la aceptación | Consolidar evidencias por plataforma, cobertura, revisión y feedback. Las pruebas técnicas están enlazadas en el Review. |

## Procedimiento de resolución

Abierto → En curso → En verificación → Resuelto. Una regresión reabre el mismo ID. Registrar cambio, entorno, caso aprobado, fecha y enlace de evidencia; una tarea arrastrada mantiene su identidad y no duplica SP.

## Correcciones verificadas del corte de entrega

| ID | Impacto observado | Resolución y comprobación | Estado / fecha |
| --- | --- | --- | --- |
| IMP-09 | Fondos y controles de modo oscuro perdían legibilidad. | Tema central, superficies diferenciadas, campos, tablas y modales; contraste mínimo 4,5:1 en combinaciones ensayadas y regresión en ambos temas. | Resuelto técnico, 09/10/2026 |
| IMP-10 | Inicio y Fin del pedido quedaban unidos visualmente. | Separación de 12 px; acciones y contenido de formulario conservados. | Resuelto técnico, 09/10/2026 |
| IMP-11 | Menú fijo ocupaba espacio y conservaba verde independiente del tema. | Superficies del tema, modo de 248/80 px, selección y navegación comprobadas mediante dos pruebas. | Resuelto técnico, 09/10/2026 |
| IMP-12 | PFA conservaba fuentes anteriores a las mejoras de interfaz. | Copia selectiva con respaldo, exclusión de configuraciones privadas y verificación de fuentes. | Resuelto técnico, 09/10/2026 |

[Resultados del corte](evidencias/REVISION_UI_Y_PRUEBAS_20261009.md). Los controles externos de aceptación conservan sus IDs IMP-07-B/08; una corrección visual no acredita por sí sola toda la DoD.

## Ajuste de alcance y disponibilidad — 09/10/2026

US-002 móvil (3 SP) se traslada a Sprint 3 por decisión del responsable; S1/S2/S3 quedan en 19/19/22 SP. La base de identidad API/Web permanece en S1 y no se duplica el esfuerzo. El cierre S1 ya no incluye una demostración de APK.

US-004 incorpora validación efectiva de la asignación: fecha y hora de salida, fin calculado con viaje y atención, turno completo del repartidor y rechazo de cruces del repartidor o vehículo. La API serializa solicitudes y no modifica pedidos al rechazar. Las rutas antiguas requieren registrar su horario mediante el calendario de Rutas. [Funcionamiento, pruebas y límites](evidencias/DISPONIBILIDAD_20261009.md).

## Historial de control de cambios

| Versión | Fecha | Responsable | Cambio |
| --- | --- | --- | --- |
| 1.0.0 | 07/10/2026 | Jordy Steve Chancasanampa Torres | Primera redacción de alcance, controles y criterios S1/S2. |
| 1.0.0, revisión de entrega | 09/10/2026 | Jordy Steve Chancasanampa Torres | Consolidación de S1/S2 con fuentes sincronizadas, 29 pruebas Flutter, 9 API, mejoras UI y conjunto ficticio de 20 rutas. |

[README principal](../../README.md)
