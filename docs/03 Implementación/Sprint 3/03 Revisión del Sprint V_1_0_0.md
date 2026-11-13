**Dictamen vigente 04/11/2026: PARCIAL para cierre académico; US-005 técnicamente demostrado.** [Cierre y evidencia](../evidencias/20261104-cierre/INFORME_CIERRE_SPRINT3.md). Los cortes anteriores se conservan como historial.

**Último corte verificado: 03/11/2026, estabilización principal y Android.** [Resultado vigente](../evidencias/20261103-estabilizacion/RESULTADOS.md). Los apartados fechados anteriores se conservan como historial.

> Corte operativo vigente: Huancayo, Junín, Perú; America/Lima es la zona horaria válida. Los apartados de cortes anteriores se conservan como historial.

[Índice de implementación](../README.md) · [README del proyecto](../../../README.md)

# Revisión del Sprint 3

**Proyecto:** EcoLogística Huancayo, adaptación de la consigna académica original de Lima. **Responsable:** Jordy Steve Chancasanampa Torres. **Sprint:** 3. **Versión:** 1.0.0. **Corte técnico:** 30/10/2026.

## Historias de Usuario completadas en este Sprint

**Incremento técnico verificado:** RF-03, generación de rutas optimizadas. Correspondencia informada: EHAPP-13 / US-005, 13 SP. Esta revisión técnica no atribuye una ceremonia, asistentes, aprobación docente ni aceptación del Product Owner que no se hayan registrado.

Como administrador, quiero generar una propuesta de rutas para mis pedidos y equipos disponibles, para revisar una distribución factible antes de asignarla.

## Demostración del trabajo completado

1. Ingresar como administrador, abrir **Rutas → Optimizar rutas**.
2. Seleccionar pedidos pendientes con coordenadas y ventanas compatibles. Agregar pares únicos de repartidor activo y vehículo activo.
3. Elegir salida en hora peruana (America/Lima) y atención por entrega. Revisar jornada, pausas, retorno, semilla y tamaño de búsqueda en parámetros avanzados.
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

## Verificación funcional adicional — 02/11/2026

| Escenario | Resultado y evidencia |
|---|---|
| GOLD Web real | ADMIN genera con GA/OSRM, revisa mapa y confirma; REPARTIDOR consulta la misma asignación, inicia, reporta incidencia y confirma entregas; ADMIN consulta resultado. PostgreSQL conserva registros tras reiniciar API. |
| Feliz / borde de capacidad | Dos pedidos de 5 kg con vehículo de 10 kg producen plan factible. Ventanas, turno y coordenadas coherentes, sin sustituir el algoritmo por datos estáticos. |
| Infeliz / datos existentes | Equipo con ruta antigua sin horario rechazado; pedidos con ventana terminada reciben diagnóstico previo visible. No se adulteran datos para aprobar. |
| Permisos y repetición | API prueba 401/403/404 según acceso, secuencia de paradas, idempotencia de entregas/incidentes, cancelación y rechazo de dirección modificada al confirmar. |

Las operaciones US-010/S5 se prueban como integración adicional autorizada, sin convertirlas en otra historia comprometida de S3 ni declarar aceptación docente. Consultar resultados, cobertura y alcance Android (archivo histórico local del corte de Lima) y pasos manuales (archivo histórico local del corte de Lima).

## Ampliación de tráfico e incidencias — verificación nocturna del 02/11/2026

| Escenario adicional | Resultado comprobado |
|---|---|
| GOLD Web | ADMIN genera y confirma → conductor inicia y completa una entrega → reporta congestión → ADMIN recibe aviso sin F5, compara y aprueba → conductor recibe versión 2, confirma recepción y termina pendientes. PostgreSQL conserva la primera entrega y tres pedidos únicos. |
| Feliz | Perfil manual por zona/día/franja cambia los tiempos evaluados por el motor y por la validación vial final, manteniendo capacidad, ventanas y turno. |
| Infeliz | Ubicación vencida, ventanas inviables, indisponibilidad del proveedor o cierre de vía sin exclusión compatible conservan la planificación anterior. |
| Borde | UUID duplicado/conflictivo, confirmaciones simultáneas, tráfico/entrega modificados durante la propuesta, versión antigua, acuse pendiente y permisos ajenos verificados en API/PostgreSQL. |
| UI y móvil | Panel probado en claro/oscuro y 360/768/1440; resultado nativo y límites separados en ANDROID.md. No se equipara una consulta nativa al GOLD móvil completo. |

**Calidad actual:** 109 backend y 71 Flutter aprobadas; 90,8811475409836 % combinado backend. No hay análisis Sonar nuevo. Los tiempos 8,02/5,05 s son del motor con matriz sintética y no acreditan EN-002 de extremo a extremo. Evidencia y capturas (archivo histórico local del corte de Lima) · Correspondencia Jira (archivo histórico local del corte de Lima).

## Corrección territorial y verificación — 03/11/2026

Demostración real Web: tres destinos públicos de Huancayo, propuesta7,469km, mapaOSM, asignación, primera entrega, congestiónQA3 min, avisoADMINsin F5, recálculo de dos pendientes4,04 km/11,10 min, aprobaciónv2, acuse efectivo y finalización de tres entregas. Diferencia0: no se afirma ahorro. Se conserva entrega anterior y persistencia tras reinicio. Ver casos negativos y evidencia en [RESULTADOS](../evidencias/20261103-huancayo/RESULTADOS.md). La evaluación/aceptación docente no se inventa.

## Demostración Web principal → Android — 03/11/2026

| Escenario | Evidencia real de este corte |
|---|---|
| GOLD por tramos persistentes | ADMIN planifica/confirma tres destinos → Android acusa/inicia/entrega una vez → congestión QA con GNSS emulado → aviso ADMIN/mapa/propuesta → aprobación v2 → acuse Android 2/2 → tres entregas únicas → reinicio API sin cambios. Los intentos monolíticos y sus fallos se distinguen de la continuación aprobada. |
| Feliz | Web repartidor consulta su recorrido finalizado e historial después del reinicio; oscuro y mapa comprobados a 360 px. |
| Infeliz | Desconexión Android conserva consulta/sesión, muestra error y recupera; flota ajena 403 y ruta ajena 404. |
| Borde | Etiquetas a 360 px y texto 200 %, mapa desmontado/recreado, acuse e inicio repetidos idempotentes, primera entrega inmutable y caso original fuera de jornada rechazado sin cambiar sus límites. |

Ruta demostrada `045076c1-d16c-4f2b-ba14-5a74a59ad97f`: FINALIZADA, v2/recibida2. La alternativa factible dio la misma distancia entre pendientes: diferencia cero. La ubicación es emulada y el tráfico es manual/simulado, no observado en vivo. [Resultados, comandos, capturas y límites](../evidencias/20261103-estabilizacion/RESULTADOS.md). La aceptación del docente y el cierre de Jira requieren revisión real.

## Revisión técnica preparada — 04/11/2026

**C1/US-005: APROBADO técnico.** Con pedidos y equipos válidos, la propuesta genética cumple capacidad/ventanas y se confirma separadamente. **C2/US-005: APROBADO técnico.** La suite vigente verifica demanda/ventanas inviables y ausencia de falsa solución válida. Las fuentes no cambiaron frente al JUnit127/Flutter81 conservados.

El nuevo GOLD Web principal completó generación → mapa → confirmación → operación del repartidor → congestión QA → aviso ADMIN → recálculo de pendientes → aprobaciónv2 → acuse2 → tres entregas → reinicio API y recarga Web. Ruta f95beaed-6a52-4905-8cd8-c468ce19ddae finalizada2/2; primera entrega inmutable y cero duplicados. Permisos API nuevos:401/403/404. La comparación de pendientes dio4,04km/19,10min contra el mismo valor, diferencia0.

**No se declara aceptación formal.** Jira sigue Tareas por hacer/future y no existe decisión docente/PO registrada. El cierre académico permanece PARCIAL por inspección manual y aceptación pendientes; Sonar actual aprobó; teléfono/release están bloqueados, y PDF no pertenece al S3 observado. [Matriz completa GOLD/feliz/infeliz/borde y estados](../evidencias/20261104-cierre/MATRIZ_ACEPTACION.md).

## Resultado SonarQube — 04/11/2026, 08:35 Perú

Proyecto **ecologisticas2.1** confirmado por Jordy. Procesamiento SUCCESS y **Quality Gate OK/PASSED**; cobertura backend **90,9 %**, cero vulnerabilidades/bugs/code smells/hotspots, duplicación0,0 %, perfiles Sonar way core. El bloqueo de análisis quedó resuelto; no se atribuye esta cifra a Flutter ni se declara cierre académico total. Los intentos sobre la clave antigua no alteraron permisos o gate. [Resultado, analysisId y límites](../evidencias/20261104-cierre/SONARQUBE_ACTUAL.md).

## Revisión del entorno consolidado — 04/11/2026

El incremento se ejecuta desde D:\UC\App\ecologistica y se entrega en PFA. El ADMIN nuevo inició sesión en el navegador; las listas de negocio están vacías por decisión del responsable, y el acceso anónimo a pedidos devuelve 401. Postgres/api/web quedaron saludables. Se conservaron las bases históricas y se verificó su restauración antes de proponer limpieza.

127 pruebas backend y 81 Flutter aprobaron nuevamente sin modificar casos ni exclusiones para elevar cobertura; el porcentaje combinado backend es 90,87591240875912 %. El HTML/XML/JUnit quedan persistidos. La revisión actual no presenta la base vacía como una nueva demostración de entregas; los recorridos reales de interfaz y emulador anteriores permanecen identificados en las evidencias de cierre. US-005 no cambia de estado en Jira ni se atribuye una aprobación docente. [Resultados, pruebas y cobertura HTML/XML](../evidencias/20261104-consolidacion/RESULTADOS.md).


## Verificación funcional del 08/11/2026

La integración ADMIN/REPARTIDOR completó por API la reoptimización y el acuse de la versión 2 con tres entregas únicas. La web del repartidor mostró el historial finalizado. Se verificó persistencia tras reinicio y se restableció la base operativa. El informe distingue las comprobaciones web, API y las pendientes. [Resultados y evidencias](../evidencias/20261108-verificacion-integral/RESULTADOS.md).

[Validación de la reoptimización Danleo del 09/11/2026](../evidencias/20261109-validacion-danleo/CIERRE_DANLEO_20261109.md)
