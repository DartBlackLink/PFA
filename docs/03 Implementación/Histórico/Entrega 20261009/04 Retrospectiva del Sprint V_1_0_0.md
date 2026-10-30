[README principal](../../../../README.md) | [Anterior](03%20Revisi%C3%B3n%20del%20Sprint%20V_1_0_0.md)

# Retrospectiva del Sprint

**Nombre del proyecto:** EcoLogística Huancayo - DistriRápido S.A.C.

**Líder del proyecto:** Jordy Steve Chancasanampa Torres

**Modalidad:** individual. **Versión documental:** 1.0.0. **Revisión de entrega:** 09/10/2026.

**Periodo del informe técnico:** 07/10/2026-09/10/2026; ejecuciones técnicas registradas el 07 y el 09/10/2026.

El documento presenta el avance técnico asociado al alcance de Sprint 1 y Sprint 2. El calendario del backlog es una línea base propuesta; las fechas de prueba identifican la evidencia real y no se atribuyen a ceremonias Scrum. La versión 1.0.0 conserva la nomenclatura de la primera entrega exigida por ambas consignas.

## Método de retrospectiva

Reflexión individual sobre el trabajo técnico registrado, usando defectos corregidos, pruebas y dificultades de operación. Los ejes de la plantilla organizan aprendizajes y acciones; no se atribuyen opiniones a personas que no participaron.

## Sprint 1

### ¿Qué aprendimos?

Autenticación, sesión y autorización son controles diferentes. Una contraseña válida no autoriza recursos ajenos; un token guardado exige comprobar vigencia. La espera del login debe persistir en el servidor para resistir recarga y solicitudes simultáneas. La migración debe usar la misma configuración que la API para no apuntar a otra base.

### ¿Qué estamos haciendo bien?

La política 5/10/300 s se comparte entre API y cliente. Las pruebas cubren límites, persistencia y concurrencia. Las migraciones explícitas y los respaldos preservan datos; la estructura de fuentes distingue clientes, API y base de datos.

### ¿Qué podemos hacer mejor?

#### Personas

Separar el tiempo de programación del de verificación aun siendo un proyecto individual. Cada cambio de identidad debe revisarse con un caso positivo y otro de rechazo.

#### Relaciones

Usar el canal académico para validar stack, modalidad y alcance. Registrar la decisión concreta, sin confundir actores ficticios del caso con participantes de una reunión.

#### Procesos

Identificar entorno y base antes de cada migración o suite. Diferenciar calendario del backlog, fecha de implementación y aceptación. El estado de Jira debe seguir la evidencia y la DoD.

#### Herramientas

Mantener API_BASE_URL y puerto Web consistentes con CORS. El error de conexión requiere revisar web, API y base por separado; reiniciar Docker no corrige por sí solo un servidor Web detenido.

### Acciones a realizar

| Acción | Responsable | Momento de aplicación | Criterio de éxito |
| --- | --- | --- | --- |
| A-S1-01: verificar destino de migración | Jordy | Antes de upgrade o pruebas | DATABASE_URL identifica la base prevista; respaldo disponible. |
| A-S1-02: revisar identidad por tres capas | Jordy | Cada modificación de acceso | Login, /auth/me y autorización aprobados. |
| A-S1-03: diferenciar plataformas | Jordy | Cada demostración | Resultado identifica Web, API o dispositivo y versión. |
| A-S1-04: consolidar aceptación | Jordy | Cierre del incremento | Casos, revisión y decisión relacionados con los elementos del backlog. |

## Sprint 2

### ¿Qué aprendimos?

Un formulario puede responder correctamente y guardar datos equivocados. Comparar entrada, DTO, columna y lectura posterior permitió separar licencia/placa y horario/contacto. La validación debe existir también en API; la base protege relaciones e integridad. Registrar horarios no equivale a evaluar toda la factibilidad temporal de una ruta.

### ¿Qué estamos haciendo bien?

Las nuevas altas capturan campos independientes, la placa se normaliza y se rechazan duplicados y valores inválidos. Las pruebas de distribución cubren distintos tamaños. La asignación usa transacciones: el fallo del proveedor no deja pedidos parcialmente asignados.

### ¿Qué podemos hacer mejor?

#### Personas

Reservar una revisión de lectura posterior por cada entidad. Usar datos sintéticos etiquetados y sustituir los datos de demostración al operar con información real.

#### Relaciones

Demostrar el mismo caso desde ADMIN y REPARTIDOR para revisar permisos y comprensión. Registrar feedback como observación, decisión y acción con responsable.

#### Procesos

Probar alta válida, entrada inválida, duplicado, edición e inactivación. Separar funciones del sprint de avances adicionales; asignación manual y optimización son capacidades diferentes.

#### Herramientas

Sincronizar nombres de campos entre Figma, Flutter y OpenAPI. Mantener el esquema SQL generado desde Alembic y comprobar el modelo documentado contra las columnas reales.

### Acciones a realizar

| Acción | Responsable | Momento de aplicación | Criterio de éxito |
| --- | --- | --- | --- |
| A-S2-01: lectura posterior y regresión | Jordy | Cada cambio CRUD | Campos, estados y errores 409/422 correctos; login conserva RN-023. |
| A-S2-02: calidad de datos históricos | Jordy | Antes de usar perfiles en operación | Identidad, licencia, contacto y origen revisados con datos reales. |
| A-S2-03: accesibilidad por pantalla | Jordy | Validación de UI | Teclado, foco, contraste y lector evaluados con resultado registrado. |
| A-S2-04: sincronización de entrega | Jordy | Antes de copiar fuentes o subir | Código probado, esquema/guías vigentes y ausencia de secretos/compilaciones. |

## Seguimiento de mejoras

Revisar acciones al cierre de cada incremento. Registrar caso, resultado y fecha; una acción se cierra por evidencia. Mantener el historial de impedimentos y preservar la identidad de tareas arrastradas para evitar doble cómputo.

## Mejoras aplicadas y seguimiento — 09/10/2026

| Acción | Aplicación comprobada | Seguimiento |
| --- | --- | --- |
| A-S2-01 | Regresión ampliada a 27 casos Flutter y 8 casos API aislados. | Repetir al modificar lógica o contrato. |
| A-S2-03 | Tema compartido, contraste de combinaciones ensayadas, modales adaptables y menú contraíble. | La evaluación integral de teclado y lector se registra antes de aceptar accesibilidad. |
| A-S2-04 | Fuentes actuales copiadas a PFA con respaldo y exclusiones; informes enlazan las mismas evidencias. | Revisar diff antes de publicar. |
| A-S2-05 | Conjunto ficticio de 6 vehículos, 6 repartidores y 20 pedidos/rutas. | Mantener identificadores PRUEBA-09/PRB09 y distinguir la demostración de una jornada real. |

Aprendizaje del corte: probar con datos variados detecta problemas que no aparecen con una sola fila; compartir el tema evita diferencias entre tablas, formularios y navegación. [Evidencia de mejoras](../../evidencias/REVISION_UI_Y_PRUEBAS_20261009.md).

## Ajuste de alcance y disponibilidad — 09/10/2026

US-002 móvil (3 SP) se traslada a Sprint 3 por decisión del responsable; S1/S2/S3 quedan en 19/19/22 SP. La base de identidad API/Web permanece en S1 y no se duplica el esfuerzo. El cierre S1 ya no incluye una demostración de APK.

US-004 incorpora validación efectiva de la asignación: fecha y hora de salida, fin calculado con viaje y atención, turno completo del repartidor y rechazo de cruces del repartidor o vehículo. La API serializa solicitudes y no modifica pedidos al rechazar. Las rutas antiguas requieren registrar su horario mediante el calendario de Rutas. [Funcionamiento, pruebas y límites](../../evidencias/DISPONIBILIDAD_20261009.md).

## Historial de control de cambios

| Versión | Fecha | Responsable | Cambio |
| --- | --- | --- | --- |
| 1.0.0 | 07/10/2026 | Jordy Steve Chancasanampa Torres | Primera redacción de alcance, controles y criterios S1/S2. |
| 1.0.0, revisión de entrega | 09/10/2026 | Jordy Steve Chancasanampa Torres | Consolidación de S1/S2 con fuentes sincronizadas, 29 pruebas Flutter, 9 API, mejoras UI y conjunto ficticio de 20 rutas. |

[README principal](../../../../README.md)
