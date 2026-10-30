[Índice de implementación](../README.md) · [README del proyecto](../../../README.md)

# Revisión del Sprint 3

**Proyecto:** EcoLogística — caso académico EcoLogística Lima; interfaz existente Huancayo. **Responsable:** Jordy Steve Chancasanampa Torres. **Sprint:** 3. **Versión:** 1.0.0. **Corte técnico:** 30/10/2026.

## Historias de Usuario completadas en este Sprint

**Incremento técnico verificado:** RF-03, generación de rutas optimizadas. Correspondencia informada: EHAPP-13 / US-005, 13 SP. Esta revisión técnica no atribuye una ceremonia, asistentes, aprobación docente ni aceptación del Product Owner que no se hayan registrado.

Como administrador, quiero generar una propuesta de rutas para mis pedidos y equipos disponibles, para revisar una distribución factible antes de asignarla.

## Demostración del trabajo completado

1. Ingresar como administrador, abrir **Rutas → Optimizar rutas**.
2. Seleccionar pedidos pendientes con coordenadas y ventanas compatibles. Agregar pares únicos de repartidor activo y vehículo activo.
3. Elegir salida en hora de Lima y atención por entrega. Revisar jornada, pausas, retorno, semilla y tamaño de búsqueda en parámetros avanzados.
4. Pulsar **Generar propuesta**. Mostrar secuencia, destinos, ETA, equipos y estimaciones. Los pedidos siguen pendientes y no hay rutas asignadas todavía.
5. Pulsar **Confirmar y asignar pedidos**. Consultar los recorridos guardados y verificar que el repartidor solo ve los suyos. No volver a confirmar para crear duplicados.
6. Mostrar un rechazo por capacidad o ventana incompatible: la aplicación informa el motivo y conserva los pedidos sin asignación parcial.

### Criterios de aceptación y evidencia ejecutada

| ID / ruta | Dado | Cuando | Entonces | Evidencia y resultado |
|---|---|---|---|---|
| S3-GOLD | Pedidos de prueba válidos, equipo elegible y ventanas compatibles | El administrador genera, revisa, confirma y consulta | Cada pedido aparece una vez, con ETA válida, geometría y asociación persistida; el repartidor propietario puede consultarla | test_gold_preview_confirm_consult_and_owner_routes, PostgreSQL real con proveedor controlado; aprobado. Pruebas Flutter GOLD en 360/768/1440 px, claro/oscuro; aprobadas. |
| S3-FELIZ | Capacidad y horarios ordinarios compatibles | Se ejecuta el GA con semilla y parámetros válidos | Se devuelve una propuesta factible y se conservan sus parámetros; no hay asignación antes de confirmar | test_genetic.py y test_optimization_api.py; aprobados. |
| S3-INFELIZ | Sobrepeso, ventana insuficiente, coordenadas ausentes o proveedor fallido | Se solicita una propuesta | Respuesta 422/503 controlada; ningún pedido cambia a ASIGNADO | test_unhappy_capacity_window_provider_and_invalid_resources; aprobado. |
| S3-INFELIZ-ACCESO | Cuenta de repartidor autenticada | Intenta consultar planes o confirmar | 403 del backend; no basta ocultar el botón | Caso GOLD verifica permisos reales; aprobado. |
| S3-BORDE | Capacidad exacta, pausa necesaria, jornada al límite o intervalos contiguos | Se evalúa el recorrido | Se respetan límites inclusivos y pausas; un exceso no se presenta como factible | test_genetic.py y pruebas de horarios existentes; aprobados. |
| S3-BORDE-CONCURRENCIA | La misma propuesta recibe dos confirmaciones simultáneas | Ambas solicitudes llegan al backend | Una sola asignación persistida, mismas rutas devueltas | test_confirmation_is_idempotent_under_concurrency; aprobado. |
| S3-BORDE-CAMBIO | Cambia pedido, capacidad o turno, o vence la propuesta | Se intenta confirmar | 409; se debe regenerar, sin rutas parciales | Pruebas parametrizadas de cambio de datos y vencimiento; aprobadas. |
| S3-BORDE-VACÍO | Pedidos/equipos vacíos, repetidos o búsqueda ya en curso | Se solicita una propuesta | 422 o 429 con Retry-After; la interfaz impide envíos ordinarios incompletos | test_optimization_api.py y optimization_test.dart; aprobados. |
| S3-BORDE-CARGA | 150 pedidos y 15 equipos sintéticos, ventanas de 8 h | Se ejecuta el motor con semilla 42, población 24 y 40 generaciones | Se atienden los 150 una sola vez y todas las restricciones se recalculan | benchmark_genetic.json: 7.907,60 ms, 15 rutas; motor solamente. El objetivo completo de 45 s requiere medición de integración. |

Las rutas GOLD conectan el flujo completo; las felices prueban operaciones válidas ordinarias; las infelices prueban respuestas controladas a errores; las de borde comprueban límites y concurrencia. [Informe técnico y archivos ejecutados](../evidencias/20261030/RESULTADOS.md).

## Pendientes

La aceptación y el calendario oficial se registrarán a partir de Jira y de la revisión real. El [análisis SonarQube del nuevo incremento](../evidencias/20261030/SONARQUBE.md) está verificado. La evaluación con lector de pantalla y la medición completa de 150/15 están diferenciadas en [Acciones externas y cierre](../evidencias/20261030/ACCIONES_EXTERNAS.md). La APK y las historias sin sprint confirmado no se presentan como terminadas aquí.
