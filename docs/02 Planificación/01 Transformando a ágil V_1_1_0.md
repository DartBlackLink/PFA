[⌂ README principal](../../README.md) | [Registro de revisión](../../REVISION_DOCUMENTAL.md) | [Guía de ajustes](../../GUIA_DE_AJUSTES_Y_CIERRE.md) | [Siguiente →](02%20Artefactos%20Jira%20V_1_1_0.md)

# Transformando a ágil

| Campo | Valor |
| --- | --- |
| Proyecto | EcoLogística Huancayo - DistriRápido S.A.C. |
| Responsable | Jordy Steve Chancasanampa Torres |
| Modalidad | Individual; responsabilidades Scrum adaptadas |
| Fecha de revisión | 07/10/2026 |
| Versión documental | 1.1.0 |
| Estado | Especificación y plan de trabajo; validación según criterios de aceptación |

## Alcance y fuentes de evidencia

EcoLogística Huancayo es la propuesta del estudiante; el escenario de evaluación sigue siendo Lima (San Juan de Lurigancho, El Agustino, Santa Anita y Ate), con RF-01 a RF-10, RNF-01 a RNF-07 y RES-01 a RES-12. Los mapas de Huancayo son una demo adicional.

Arquitectura objetivo: Web ADMIN con preferencias CLIENTE (RF-09), móvil REPARTIDOR, FastAPI y PostgreSQL. Este documento define el diseño y sus criterios de validación. Las acciones de implementación, Jira, Figma y evidencias se coordinan en la guía de ajustes.

## Responsabilidades y cadencia

Jordy asume planificación de producto, facilitación y desarrollo en una adaptación individual. La revisión docente o por par debe registrarse cuando ocurra; no se inventa un revisor. Cadencia objetivo: siete sprints de dos semanas. Las cuatro iteraciones académicas de la consigna son hitos y no equivalen a siete sprints. Calendario propuesto: 12/10/2026-18/01/2027; S1 12-26/10 y S2 26/10-09/11. Revisar capacidad en cada Planning y ajustar el plan completo si cambia el inicio.

| Épica | Nombre |
| --- | --- |
| EP-01 | Acceso y seguridad |
| EP-02 | Recursos logísticos |
| EP-03 | Pedidos y clientes |
| EP-04 | Optimización |
| EP-05 | Operación de rutas |
| EP-06 | Sostenibilidad |
| EP-07 | UX/Calidad |

## Backlog canónico

| ID | Historia | Épica | RF/RNF | Sprint objetivo | SP |
| --- | --- | --- | --- | --- | --- |
| US-001 | Autenticación administrador | EP-01 | Transversal / RNF-02 | S1 | 3 |
| US-002 | Autenticación repartidor | EP-01 | Transversal / RNF-02 | S1 | 3 |
| US-003 | Gestionar flota | EP-02 | RF-01 | S2 | 5 |
| US-004 | Gestionar repartidores | EP-02 | RF-08 | S2 | 5 |
| US-005 | Gestionar pedidos | EP-03 | RF-02 | S3 | 8 |
| US-006 | Clientes y preferencias | EP-03 | RF-09 | S3 | 5 |
| US-007 | Generar rutas optimizadas | EP-04 | RF-03 | S4 | 13 |
| US-008 | Visualizar mapa global | EP-05 | RF-04 | S5 | 8 |
| US-009 | Consultar mi ruta | EP-05 | RF-04 | S5 | 8 |
| US-010 | Entrega e incidente | EP-05 | RF-07 | S5 | 5 |
| US-011 | Reoptimizar rutas | EP-04 | RF-07 | S6 | 8 |
| US-012 | Consultar dashboard | EP-06 | RF-05 | S6 | 5 |
| US-013 | Generar reporte PDF | EP-06 | RF-06 | S6 | 5 |
| US-014 | Plan de compensación | EP-06 | RF-10 | S7 | 5 |

## Historias completas

### US-001 - Autenticación administrador

**Épica:** EP-01. **Requisito:** Transversal / RNF-02. **Sprint objetivo:** S1. **Estimación:** 3 SP. **Estado de planificación:** To Do; cierre conforme a BDD y DoD.

Como **Administrador**, quiero **iniciar sesión en Web y cerrar mi sesión**, para **administrar sin acceso no autorizado**.

**Credenciales válidas**

- **Dado** un usuario ADMIN activo.
- **Cuando** inicia sesión desde Web con credenciales válidas.
- **Entonces** la API emite sesión limitada por rol y la interfaz permite cerrar sesión.

**Credenciales o sesión inválidas**

- **Dado** contraseña incorrecta, usuario inactivo o token vencido.
- **Cuando** se intenta acceder a un recurso protegido.
- **Entonces** se rechaza el acceso sin mostrar datos y se solicita autenticación cuando corresponda.

**Bloqueo progresivo**

- **Dado** tres fallos consecutivos de credenciales.
- **Cuando** la API procesa el tercero, el cuarto tras la espera y el quinto tras la nueva espera.
- **Entonces** aplica 5 s, 10 s y 300 s respectivamente; la interfaz muestra el contador y bloquea el envío.

**Persistencia y reinicio**

- **Dado** un bloqueo activo y el mismo usuario en otra sesión.
- **Cuando** recarga o reintenta antes del plazo, y luego accede correctamente al vencerlo.
- **Entonces** no evita ni extiende el bloqueo; el éxito reinicia contador y plazo, y el siguiente fallo cuenta como primero.

**Dependencias y evidencia:** datos del RF, autenticación, modelo/contrato y mockup del canal. Adjuntar caso de prueba, resultado y commit; en historias de cálculo, dataset/semilla. En US-006 incluir además el registro asistido de RF-09.

### US-002 - Autenticación repartidor

**Épica:** EP-01. **Requisito:** Transversal / RNF-02. **Sprint objetivo:** S1. **Estimación:** 3 SP. **Estado de planificación:** To Do; cierre conforme a BDD y DoD.

Como **Repartidor**, quiero **iniciar sesión desde el cliente móvil**, para **acceder a mi operación asignada**.

**Credenciales válidas**

- **Dado** un usuario REPARTIDOR activo.
- **Cuando** inicia sesión desde móvil con credenciales válidas.
- **Entonces** la API emite sesión limitada por rol y la interfaz permite cerrar sesión.

**Credenciales o sesión inválidas**

- **Dado** contraseña incorrecta, usuario inactivo o token vencido.
- **Cuando** se intenta acceder a un recurso protegido.
- **Entonces** se rechaza el acceso sin mostrar datos y se solicita autenticación cuando corresponda.

**Bloqueo progresivo**

- **Dado** tres fallos consecutivos de credenciales.
- **Cuando** la API procesa el tercero, el cuarto tras la espera y el quinto tras la nueva espera.
- **Entonces** aplica 5 s, 10 s y 300 s respectivamente; la interfaz muestra el contador y bloquea el envío.

**Persistencia y reinicio**

- **Dado** un bloqueo activo y el mismo usuario en otra sesión.
- **Cuando** recarga o reintenta antes del plazo, y luego accede correctamente al vencerlo.
- **Entonces** no evita ni extiende el bloqueo; el éxito reinicia contador y plazo, y el siguiente fallo cuenta como primero.

**Dependencias y evidencia:** datos del RF, autenticación, modelo/contrato y mockup del canal. Adjuntar caso de prueba, resultado y commit; en historias de cálculo, dataset/semilla. En US-006 incluir además el registro asistido de RF-09.

### US-003 - Gestionar flota

**Épica:** EP-02. **Requisito:** RF-01. **Sprint objetivo:** S2. **Estimación:** 5 SP. **Estado de planificación:** To Do; cierre conforme a BDD y DoD.

Como **Administrador**, quiero **registrar, actualizar e inactivar vehículos**, para **planificar con capacidades y emisiones correctas**.

**Aceptación principal**

- **Dado** una placa no registrada y un administrador autenticado.
- **Cuando** registra una camioneta de 800 kg, 10 km/L y 0.18 kg CO₂/km.
- **Entonces** se persisten todos los campos y se devuelve su identificador.

**Rechazo y consistencia**

- **Dado** la placa ABC-123 ya registrada.
- **Cuando** se intenta registrar otra unidad con esa placa o capacidad cero.
- **Entonces** se rechaza la operación con error de campo y no se crea un duplicado.

**Dependencias y evidencia:** datos del RF, autenticación, modelo/contrato y mockup del canal. Adjuntar caso de prueba, resultado y commit; en historias de cálculo, dataset/semilla. En US-006 incluir además el registro asistido de RF-09.

### US-004 - Gestionar repartidores

**Épica:** EP-02. **Requisito:** RF-08. **Sprint objetivo:** S2. **Estimación:** 5 SP. **Estado de planificación:** To Do; cierre conforme a BDD y DoD.

Como **Administrador**, quiero **registrar licencia, contacto, disponibilidad y origen**, para **asignar conductores elegibles**.

**Aceptación principal**

- **Dado** un DNI no registrado y licencia informada.
- **Cuando** se registra disponibilidad 08:00 a 16:00 con punto de partida confirmado.
- **Entonces** se persisten los campos sin confundir licencia, placa, contacto y horario.

**Rechazo y consistencia**

- **Dado** un DNI duplicado o ruta que excede disponibilidad.
- **Cuando** se registra el duplicado o se asigna la ruta.
- **Entonces** se rechaza la acción con causa y no se crea la asignación incompatible.

**Dependencias y evidencia:** datos del RF, autenticación, modelo/contrato y mockup del canal. Adjuntar caso de prueba, resultado y commit; en historias de cálculo, dataset/semilla. En US-006 incluir además el registro asistido de RF-09.

### US-005 - Gestionar pedidos

**Épica:** EP-03. **Requisito:** RF-02. **Sprint objetivo:** S3. **Estimación:** 8 SP. **Estado de planificación:** To Do; cierre conforme a BDD y DoD.

Como **Administrador**, quiero **registrar pedidos completos y georreferenciados**, para **preparar entradas válidas del optimizador**.

**Aceptación principal**

- **Dado** un cliente y coordenadas confirmadas en Lima.
- **Cuando** se registra un pedido de 10 kg y 0.1 m³ con ventana 09:00 a 11:00.
- **Entonces** se guarda el pedido con datos completos y queda disponible para planificación.

**Rechazo y consistencia**

- **Dado** un pedido con ventana invertida o ubicación sin resolver.
- **Cuando** se intenta guardar la ventana inválida o incluir el borrador en optimización.
- **Entonces** se rechaza la ventana inválida y el pedido sin coordenadas queda excluido con causa explícita.

**Dependencias y evidencia:** datos del RF, autenticación, modelo/contrato y mockup del canal. Adjuntar caso de prueba, resultado y commit; en historias de cálculo, dataset/semilla. En US-006 incluir además el registro asistido de RF-09.

### US-006 - Clientes y preferencias

**Épica:** EP-03. **Requisito:** RF-09. **Sprint objetivo:** S3. **Estimación:** 5 SP. **Estado de planificación:** To Do; cierre conforme a BDD y DoD.

Como **Cliente**, quiero **guardar mis preferencias desde el área Web restringida**, para **recibir entregas en condiciones acordadas**.

**Aceptación principal**

- **Dado** un cliente autenticado.
- **Cuando** guarda una preferencia 06:00 a 09:00 y acceso por puerta lateral.
- **Entonces** se conserva la preferencia asociada exclusivamente a ese cliente.

**Rechazo y consistencia**

- **Dado** un cliente que intenta cambiar preferencias ajenas o un horario inválido.
- **Cuando** envía el cambio.
- **Entonces** se deniega el recurso ajeno o se rechaza el horario y se conserva el valor anterior.

**Dependencias y evidencia:** datos del RF, autenticación, modelo/contrato y mockup del canal. Adjuntar caso de prueba, resultado y commit; en historias de cálculo, dataset/semilla. En US-006 incluir además el registro asistido de RF-09.

### US-007 - Generar rutas optimizadas

**Épica:** EP-04. **Requisito:** RF-03. **Sprint objetivo:** S4. **Estimación:** 13 SP. **Estado de planificación:** To Do; cierre conforme a BDD y DoD.

Como **Administrador**, quiero **ejecutar el algoritmo genético con recursos y restricciones**, para **obtener un plan factible con costos y emisiones medibles**.

**Aceptación principal**

- **Dado** un dataset factible de hasta 150 pedidos y 15 vehículos.
- **Cuando** el administrador ejecuta el algoritmo genético.
- **Entonces** se obtiene en ≤45 s un plan sin violaciones duras, con secuencia, ETA, métricas, semilla y parámetros persistidos.

**Rechazo y consistencia**

- **Dado** demanda que excede capacidad o disponibilidad.
- **Cuando** se solicita una optimización.
- **Entonces** se reportan pedidos no asignados con causa y ninguna ruta inválida se marca como factible.

**Dependencias y evidencia:** datos del RF, autenticación, modelo/contrato y mockup del canal. Adjuntar caso de prueba, resultado y commit; en historias de cálculo, dataset/semilla. En US-006 incluir además el registro asistido de RF-09.

### US-008 - Visualizar mapa global

**Épica:** EP-05. **Requisito:** RF-04. **Sprint objetivo:** S5. **Estimación:** 8 SP. **Estado de planificación:** To Do; cierre conforme a BDD y DoD.

Como **Administrador**, quiero **consultar rutas, ETA y capas de contexto**, para **supervisar la planificación de Lima**.

**Aceptación principal**

- **Dado** un plan válido de Lima.
- **Cuando** ADMIN abre el mapa.
- **Entonces** se muestran trazado, paradas, ETA, límites y origen de los datos; consultar no modifica la asignación.

**Rechazo y consistencia**

- **Dado** un repartidor que conoce el identificador de una ruta ajena.
- **Cuando** intenta consultarla.
- **Entonces** la API deniega el acceso sin exponer pedidos ni coordenadas ajenas.

**Dependencias y evidencia:** datos del RF, autenticación, modelo/contrato y mockup del canal. Adjuntar caso de prueba, resultado y commit; en historias de cálculo, dataset/semilla. En US-006 incluir además el registro asistido de RF-09.

### US-009 - Consultar mi ruta

**Épica:** EP-05. **Requisito:** RF-04. **Sprint objetivo:** S5. **Estimación:** 8 SP. **Estado de planificación:** To Do; cierre conforme a BDD y DoD.

Como **Repartidor**, quiero **consultar exclusivamente mis paradas y siguiente entrega**, para **ejecutar mi asignación con información suficiente**.

**Ruta propia**

- **Dado** un repartidor con asignación.
- **Cuando** consulta Mi ruta.
- **Entonces** se muestran únicamente paradas, próxima entrega y ETA de su asignación.

**Ruta ajena**

- **Dado** un segundo repartidor con otra asignación.
- **Cuando** se solicita el identificador de la ruta ajena.
- **Entonces** la API deniega acceso y no expone el contenido.

**Dependencias y evidencia:** datos del RF, autenticación, modelo/contrato y mockup del canal. Adjuntar caso de prueba, resultado y commit; en historias de cálculo, dataset/semilla. En US-006 incluir además el registro asistido de RF-09.

### US-010 - Entrega e incidente

**Épica:** EP-05. **Requisito:** RF-07. **Sprint objetivo:** S5. **Estimación:** 5 SP. **Estado de planificación:** To Do; cierre conforme a BDD y DoD.

Como **Repartidor**, quiero **actualizar mis entregas y reportar eventos de ruta**, para **mantener informada la operación**.

**Evento propio**

- **Dado** una entrega propia pendiente.
- **Cuando** el repartidor confirma entrega o registra avería con identificador de evento.
- **Entonces** se persiste estado/fecha/autor y se notifica el evento a la operación.

**Evento duplicado o ajeno**

- **Dado** evento ya aplicado o pedido ajeno.
- **Cuando** se repite la solicitud o se cruza el identificador.
- **Entonces** se evita duplicar efectos y se deniega el recurso ajeno.

**Dependencias y evidencia:** datos del RF, autenticación, modelo/contrato y mockup del canal. Adjuntar caso de prueba, resultado y commit; en historias de cálculo, dataset/semilla. En US-006 incluir además el registro asistido de RF-09.

### US-011 - Reoptimizar rutas

**Épica:** EP-04. **Requisito:** RF-07. **Sprint objetivo:** S6. **Estimación:** 8 SP. **Estado de planificación:** To Do; cierre conforme a BDD y DoD.

Como **Administrador**, quiero **recalcular el trabajo pendiente ante eventos**, para **mantener un plan vigente y trazable**.

**Aceptación principal**

- **Dado** una ruta activa y una avería reportada.
- **Cuando** se confirma el evento y se ejecuta reoptimización.
- **Entonces** en <30 s se genera un plan factible o diagnóstico de imposibilidad, preservando entregas completadas y registro del evento.

**Rechazo y consistencia**

- **Dado** un fallo del cálculo o notificación.
- **Cuando** se intenta reemplazar el plan vigente.
- **Entonces** no se publica una asignación incompleta y se conserva el último plan confirmado con estado de incidencia.

**Dependencias y evidencia:** datos del RF, autenticación, modelo/contrato y mockup del canal. Adjuntar caso de prueba, resultado y commit; en historias de cálculo, dataset/semilla. En US-006 incluir además el registro asistido de RF-09.

### US-012 - Consultar dashboard

**Épica:** EP-06. **Requisito:** RF-05. **Sprint objetivo:** S6. **Estimación:** 5 SP. **Estado de planificación:** To Do; cierre conforme a BDD y DoD.

Como **Administrador**, quiero **ver métricas derivadas de rutas y su línea base**, para **evaluar ahorro, emisiones y puntualidad**.

**Aceptación principal**

- **Dado** rutas optimizada y secuencial para los mismos pedidos y parámetros.
- **Cuando** se consulta el periodo.
- **Entonces** se muestran métricas reproducibles, unidades, fórmula de ahorro y fecha de actualización.

**Rechazo y consistencia**

- **Dado** una línea base de distancia cero.
- **Cuando** se solicita porcentaje de ahorro.
- **Entonces** el indicador se informa no calculable y no se divide entre cero.

**Dependencias y evidencia:** datos del RF, autenticación, modelo/contrato y mockup del canal. Adjuntar caso de prueba, resultado y commit; en historias de cálculo, dataset/semilla. En US-006 incluir además el registro asistido de RF-09.

### US-013 - Generar reporte PDF

**Épica:** EP-06. **Requisito:** RF-06. **Sprint objetivo:** S6. **Estimación:** 5 SP. **Estado de planificación:** To Do; cierre conforme a BDD y DoD.

Como **Administrador**, quiero **descargar un reporte de sostenibilidad y TCO**, para **sustentar resultados con datos y supuestos**.

**Aceptación principal**

- **Dado** un periodo con rutas y costos documentados.
- **Cuando** ADMIN solicita un reporte.
- **Entonces** se descarga un PDF legible con identificador, métricas reconciliables con dashboard y desglose TCO.

**Rechazo y consistencia**

- **Dado** un periodo con fecha final anterior a la inicial.
- **Cuando** se solicita el PDF.
- **Entonces** se rechaza la petición y no se genera un archivo con periodo inválido.

**Dependencias y evidencia:** datos del RF, autenticación, modelo/contrato y mockup del canal. Adjuntar caso de prueba, resultado y commit; en historias de cálculo, dataset/semilla. En US-006 incluir además el registro asistido de RF-09.

### US-014 - Plan de compensación

**Épica:** EP-06. **Requisito:** RF-10. **Sprint objetivo:** S7. **Estimación:** 5 SP. **Estado de planificación:** To Do; cierre conforme a BDD y DoD.

Como **Administrador**, quiero **estimar reducción y compensación a tres años**, para **planificar emisiones residuales sin afirmar compensación no realizada**.

**Aceptación principal**

- **Dado** emisiones anuales y factor de absorción documentado.
- **Cuando** se calcula una propuesta.
- **Entonces** se muestra número de árboles redondeado hacia arriba, horizonte, fuente y condición de estimación.

**Rechazo y consistencia**

- **Dado** factor de absorción ausente o igual a cero.
- **Cuando** se pide cantidad de árboles.
- **Entonces** se informa no calculable y no se declara neutralidad ni compensación acreditada.

**Dependencias y evidencia:** datos del RF, autenticación, modelo/contrato y mockup del canal. Adjuntar caso de prueba, resultado y commit; en historias de cálculo, dataset/semilla. En US-006 incluir además el registro asistido de RF-09.

## Enablers completos

### EN-001 - Base reproducible y separación de clientes

**Épica:** EP-07. **Ventana:** S1. **Estimación agregada:** 3 SP. **Estado:** planificado.

Como responsable técnico, quiero **estructura Web/móvil/API**, para **reproducir entorno y despliegues independientes**.

**Aceptación**

- **Dado** un clon limpio y las dependencias documentadas.
- **Cuando** se siguen las instrucciones del entorno de prueba.
- **Entonces** se construyen clientes Web/móvil y API por comandos independientes, con health y sin secretos versionados.

**Control de falla**

- **Dado** un archivo temporal o variable de entorno local.
- **Cuando** se revisa el conjunto de archivos rastreados.
- **Entonces** las dependencias, builds y secretos quedan excluidos; un ejemplo de configuración contiene solo valores ficticios.

### EN-002 - BD y migraciones

**Épica:** EP-07. **Ventana:** S1. **Estimación agregada:** 5 SP. **Estado:** planificado.

Como responsable técnico, quiero **esquema consistente y migraciones explícitas**, para **preservar datos e integridad**.

**Aceptación**

- **Dado** una BD vacía.
- **Cuando** se aplica la migración versionada.
- **Entonces** se crean tablas, FK, CHECK e índices del diseño y el estado de revisión coincide.

**Control de falla**

- **Dado** una ventana invertida, placa duplicada o consumo cero.
- **Cuando** se intenta persistir el dato.
- **Entonces** se rechaza sin pérdida de registros previos y se devuelve un error de dominio.

### EN-003 - Seguridad y privacidad

**Épica:** EP-01. **Ventana:** S1/S3/S4/S7. **Estimación agregada:** 12 SP. **Estado:** planificado.

Como responsable técnico, quiero **RBAC por rol y propietario, validación y análisis estático**, para **evitar acceso indebido**.

**Aceptación**

- **Dado** dos repartidores, dos clientes y tokens válidos.
- **Cuando** se cruzan identificadores de recursos.
- **Entonces** se deniegan todos los accesos ajenos y se conserva evidencia de RNF-02.

**Control de falla**

- **Dado** un token vencido o hallazgo crítico del escáner.
- **Cuando** se consulta un recurso o se intenta liberar versión.
- **Entonces** se rechaza la sesión o se bloquea el release hasta corregir y repetir las pruebas.

Aplicación RN-023 en EN-003-S1: estado atómico persistente, API 429/Retry-After, contador Web/móvil, credenciales genéricas y pruebas 5/10/300 s. Implementar una sola política compartida, sin duplicar SP entre US-001 y US-002.

### EN-004 - Benchmark del motor

**Épica:** EP-04. **Ventana:** S4/S6. **Estimación agregada:** 8 SP. **Estado:** planificado.

Como responsable técnico, quiero **dataset, semillas, tiempos y factibilidad registrados**, para **demostrar rendimiento reproducible**.

**Aceptación**

- **Dado** dataset fijo 150/15 y cinco semillas.
- **Cuando** se ejecuta cálculo completo.
- **Entonces** cada ejecución tarda ≤45 s y se publican máximo, mediana y violaciones.

**Control de falla**

- **Dado** un evento operativo sobre el mismo tamaño.
- **Cuando** se mide reoptimización.
- **Entonces** cada ejecución tarda <30 s y conserva completadas; cualquier fallo impide aprobar RNF-01.

### EN-005 - Accesibilidad

**Épica:** EP-07. **Ventana:** S2/S7. **Estimación agregada:** 6 SP. **Estado:** planificado.

Como responsable técnico, quiero **teclado, semántica, contraste y alternativa textual**, para **permitir uso inclusivo**.

**Aceptación**

- **Dado** flujos críticos a 360, 768 y 1440 px.
- **Cuando** se usa teclado y lector de pantalla.
- **Entonces** se completan tareas con foco visible, etiquetas y sin bloqueo.

**Control de falla**

- **Dado** un mapa o mensaje identificado solo por color.
- **Cuando** se audita WCAG 2.1 AA.
- **Entonces** se proporciona texto equivalente y se verifica contraste de RNF-03.

### EN-006 - Escala y rendimiento API

**Épica:** EP-07. **Ventana:** S6/S7. **Estimación agregada:** 6 SP. **Estado:** planificado.

Como responsable técnico, quiero **dos réplicas API y prueba de carga**, para **soportar crecimiento con métricas**.

**Aceptación**

- **Dado** 1,000 pedidos diarios, 50 vehículos y 20 usuarios concurrentes.
- **Cuando** se ejecuta carga de gestión 15 min.
- **Entonces** se obtiene p95 ≤2 s, <1% errores inesperados y expediente de hardware.

**Control de falla**

- **Dado** dos réplicas con peticiones distribuidas.
- **Cuando** se consulta una asignación y se solicita cálculo.
- **Entonces** ninguna depende de memoria local exclusiva; se documentan lotes y tiempos del motor por separado.

### EN-007 - Diseño y usabilidad

**Épica:** EP-07. **Ventana:** S1/S2. **Estimación agregada:** 8 SP. **Estado:** planificado.

Como responsable técnico, quiero **mockups por rol y protocolo de tareas**, para **validar formularios antes de consolidar UI**.

**Aceptación**

- **Dado** mockups y una lista de campos RF.
- **Cuando** se realiza recorrido por roles.
- **Entonces** se registra cobertura de pantallas, campos, errores y estados vacíos; el acceso directo de cliente se incluye como pendiente si falta.

**Control de falla**

- **Dado** al menos cinco participantes voluntarios.
- **Cuando** se prueban pedido y próxima entrega.
- **Entonces** se registra éxito ≥80% y medianas de RNF-05, o se declara la evaluación exploratoria sin atribuir cumplimiento.

### EN-008 - Disponibilidad y contingencia

**Épica:** EP-07. **Ventana:** S5/S7. **Estimación agregada:** 6 SP. **Estado:** planificado.

Como responsable técnico, quiero **caché autorizada, cola de eventos y restauración**, para **operar ante desconexión**.

**Aceptación**

- **Dado** una ruta sincronizada.
- **Cuando** se corta la red del móvil.
- **Entonces** se muestra la última asignación con fecha y eventos pendientes diferenciados.

**Control de falla**

- **Dado** un respaldo diario y falla controlada.
- **Cuando** se restaura y reconecta.
- **Entonces** se mide RTO ≤30 min, RPO ≤24 h y se evita duplicar eventos por idempotencia.

### EN-009 - Documentación y contrato

**Épica:** EP-07. **Ventana:** S2/S3/S7. **Estimación agregada:** 9 SP. **Estado:** planificado.

Como responsable técnico, quiero **OpenAPI, manuales y trazabilidad actualizados**, para **reproducir y evaluar el release**.

**Aceptación**

- **Dado** una versión candidata y sus endpoints.
- **Cuando** se compara código, OpenAPI y manuales.
- **Entonces** 100% de endpoints liberados y pasos de instalación están documentados con estados reales.

**Control de falla**

- **Dado** un RF o esquema cambiado.
- **Cuando** se revisa el expediente documental.
- **Entonces** se actualizan historia, prueba y versión; no quedan enlaces locales rotos ni afirmaciones de pruebas no ejecutadas.

## Subdivisión de trabajo técnico

Los EN son padres de capacidad. Cada porción tiene identificador único EN-XXX-Sn, sprint y estimación propia en Artefactos Jira. No se cuenta dos veces el padre y sus porciones. Un mismo issue ejecutable no pertenece a varios sprints simultáneamente. Los 13 SP de US-007 exigen refinamiento y subtareas antes de compromiso. La capacidad inicial es hipótesis; se ajusta con velocidad observada, no con una velocidad inventada.

## Definition of Ready

Actor, valor, criterios BDD, RF/RNF, dependencias, datos de prueba, mockup suficiente, estimación y capacidad disponible. Falta de acceso a una API o de aprobación tecnológica se registra como riesgo, no se oculta como tarea lista.

## Definition of Done

- Criterios de aceptación aprobados con resultados y evidencia.
- Pruebas unitarias e integración; cobertura ≥80% de lógica testeable, con exclusiones explícitas y reporte.
- Análisis estático y dependencias sin hallazgos críticos pendientes.
- Revisión por par técnico mediante PR y evidencia; la auto-revisión individual es preparación y no sustituye ese requisito de la guía. Si no existe par disponible, registrar impedimento y validación docente de la adaptación.
- Despliegue automatizado en entorno de pruebas con resultado registrado.
- OpenAPI, migraciones, manuales y documentación aplicable actualizados.
- RNF aplicables y permisos por recurso verificados; diseño y accesibilidad revisados.
- Issue enlazado a código, pruebas y evidencia. Nunca pasar a Done por apariencia de pantalla.

## Review y retrospectiva

Review: mostrar incremento integrado, separar completado y pendiente y registrar fecha, participantes reales y feedback. Retrospectiva: registrar aprendizaje y mejora por personas, relaciones, procesos y herramientas con responsable, fecha y condición de éxito. Los cuatro documentos de Implementación detallan S1/S2, casos y acciones. Jira usa esos objetivos y criterios; la guía de ajustes reúne la obtención de resultados y capturas para el cierre.

## Historial de control de cambios

| Versión | Fecha | Responsable | Cambio |
|---|---|---|---|
| 1.0.0 | 27/09/2026 | Jordy Steve Chancasanampa Torres | Versión previa del repositorio; conservada en historial Git y respaldo de revisión. |
| 1.1.0 | 07/10/2026 | Jordy Steve Chancasanampa Torres | Refinamiento documental: requisitos verificables, trazabilidad, decisiones y estado real de evidencias. Calendario propuesto, RN-023 y guía de ajustes alineados. Sin modificación del software ni cierre de sprint. |

[⌂ README principal](../../README.md) | [Registro de revisión](../../REVISION_DOCUMENTAL.md) | [Guía de ajustes](../../GUIA_DE_AJUSTES_Y_CIERRE.md) | [Siguiente →](02%20Artefactos%20Jira%20V_1_1_0.md)
