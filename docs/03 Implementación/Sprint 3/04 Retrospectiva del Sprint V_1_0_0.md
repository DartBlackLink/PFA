**Borrador pendiente de validación formal.** La demostración técnica de EHAPP-13 / US-005 está documentada. La inspección académica y la aceptación formal siguen pendientes. El último seguimiento funcional incorporado corresponde al 09/11/2026. [Dictamen académico](../evidencias/20261104-cierre/INFORME_CIERRE_SPRINT3.md) · [Verificación de Huancayo del 09/11](../evidencias/20261109-validacion-danleo/CIERRE_DANLEO_20261109.md).

> Corte operativo vigente: Huancayo, Junín, Perú; America/Lima es la zona horaria válida. Los apartados de cortes anteriores se conservan como historial.

[Índice de implementación](../README.md) · [README del proyecto](../../../README.md)

# Retrospectiva del Sprint 3

**Proyecto:** EcoLogística Huancayo, adaptación de la consigna académica original de Lima.

**Responsable:** Jordy Steve Chancasanampa Torres.

**Sprint:** 3. **Versión:** 1.0.0. **Corte inicial:** 30/10/2026. **Seguimiento técnico incorporado:** 09/11/2026.

**Método:** reflexión individual basada en los problemas encontrados al implementar y comprobar el incremento. Se distinguen defectos corregidos, controles preventivos y asuntos que requieren seguimiento. Los compromisos preventivos son propuestas para confirmar con el responsable. Los plazos se expresan por hito de trabajo.

## Problemas que tuvimos y cómo los solucionamos

### R3-01. Existían recorridos, pero faltaba generar la planificación genética

**Problema:** la aplicación permitía asignar pedidos y mostrar recorridos. Eso no demostraba que distribuyera los pedidos entre equipos mediante un algoritmo genético ni que la propuesta cumpliera todas las restricciones.

**Causa:** la asignación manual y la representación del mapa resolvían partes del proceso, pero todavía no existía el motor genético.

**Solución aplicada:** se implementó GA_VRPTW_1 y su integración con API y Web. El administrador selecciona pares de repartidor y vehículo; el motor distribuye y ordena pedidos considerando capacidad, ventanas, atención por entrega, turno, jornada, descansos y ocupaciones existentes. Una propuesta incompleta no se presenta como válida.

**Qué aprendimos:** debemos comprobar cada restricción y cada pedido del resultado; dibujar una línea en el mapa o recibir una respuesta exitosa no demuestra que la planificación sea factible.

### R3-02. La propuesta podía dejar de ser válida antes de confirmarse

**Problema identificado como riesgo:** un pedido, vehículo o turno puede cambiar después del cálculo. También pueden llegar dos solicitudes de confirmación simultáneamente. No se atribuye a producción un incidente de duplicación que no se haya observado.

**Solución aplicada:** se separó la vista previa de la asignación. La propuesta vence en diez minutos y mantiene los pedidos pendientes. Al confirmar se comprueban cambios, se bloquean los recursos necesarios y se guarda la asignación en una transacción. Repetir una confirmación no crea nuevas rutas.

**Comprobación:** las pruebas verificaron rechazo de propuestas vencidas o modificadas y confirmaciones concurrentes sin asignaciones duplicadas.

**Qué aprendimos:** la validación del formulario no sustituye la comprobación del servidor justo antes de guardar. Una operación rechazada debe conservar los pedidos y evitar asignaciones parciales.

### R3-03. Los controles se desbordaban en pantallas pequeñas

**Problema:** las pruebas detectaron un desbordamiento de controles a 360 px en los temas claro y oscuro.

**Causa:** la distribución inicial utilizaba una fila rígida que dependía del espacio disponible en escritorio.

**Corrección aplicada:** se sustituyó por una distribución que permite colocar los controles en varias líneas. Se repitió el flujo en 360, 768 y 1440 px, con ambos temas.

**Qué aprendimos:** debemos revisar los estados y operaciones reales en distintos tamaños. Una pantalla que se ve correctamente en escritorio puede fallar al seleccionar, validar o confirmar desde una ventana pequeña.

### R3-04. Existía riesgo de incluir configuración privada en la Web

**Problema:** Flutter declaraba .env como recurso mientras ese archivo también se usaba para configurar el backend.

**Causa:** se utilizó un mismo mecanismo de configuración para responsabilidades distintas: datos públicos del cliente y configuración privada del servidor.

**Corrección aplicada:** se retiraron flutter_dotenv y el recurso .env. La URL pública API_BASE_URL pasó a configurarse durante la compilación. La inspección del artefacto Web confirmó que no incluía .env ni las claves privadas del backend. No se constató una exposición de esas claves en la compilación anterior revisada.

**Qué aprendimos:** ignorar un archivo en Git no evita que termine empaquetado en una aplicación. Debemos revisar tanto el repositorio como el contenido de la compilación.

### R3-05. La consulta de rutas multiplicaba las lecturas de base de datos

**Problema:** al serializar cada ruta se consultaban individualmente su repartidor, vehículo y entregas.

**Causa:** las lecturas estaban dentro del procesamiento de cada registro, por lo que podían aumentar al listar más rutas.

**Corrección aplicada:** se cargaron los recursos y las entregas por lotes. La prueba comprobó cuatro SELECT para una ruta y también para cuatro rutas, incluyendo la consulta de rutas y excluyendo autenticación.

**Qué aprendimos:** un listado puede devolver datos correctos y aun así realizar trabajo innecesario. La mejora debe comprobarse con una medición; reducir consultas no demuestra por sí solo un ahorro de energía o de tiempo en producción.

### R3-06. El análisis de SonarQube apuntaba a una clave de proyecto incorrecta

**Problema:** el intento sobre ecologistica2 fue rechazado por autorización o destino. El responsable confirmó que el token correspondía a ecologisticas.

**Corrección aplicada:** se ejecutó el análisis con la clave correcta. El escáner terminó satisfactoriamente. Una consulta posterior del lanzador devolvió un error HTTP; se recuperó y verificó el resultado mediante la tarea y su analysisId, sin repetir el análisis ni cambiar permisos o el Quality Gate.

**Qué aprendimos:** debemos distinguir un fallo del análisis de un fallo al consultar sus resultados. La clave del proyecto, el estado de procesamiento y el identificador del análisis deben quedar registrados antes de informar que aprobó.

### R3-07. La retrospectiva no mostraba las métricas que respaldaban sus afirmaciones

**Problema:** el documento describía verificaciones de forma general, sin presentar claramente cobertura, cantidad de pruebas y resultado de SonarQube.

**Corrección documental:** se incorporó el cuadro siguiente, diferenciando cobertura local, cobertura Sonar y pruebas Flutter.

**Qué aprendimos:** una afirmación de calidad necesita fecha, alcance y evidencia. No debemos presentar cobertura como una nota global ni atribuir los resultados a otra versión del código.

### R3-08. El comparador podía dar a entender que la ruta verde ahorraba tiempo

**Problema y efecto.** En la demostración de Huancayo, el mapa mostró dos geometrías distintas, pero ambas opciones obtuvieron 4,0404 km y 19,10 min para el tramo pendiente. Interpretar el color como ahorro habría llevado a una conclusión que las mediciones no respaldan.

**Causa e investigación.** Se contrastaron los puntos de las geometrías, el orden de paradas, la consulta a OSRM y la demora informada. La geometría roja incluía el recorrido previo y la verde empezaba desde la ubicación confirmada. La comparación de métricas utilizó la misma salida y el mismo orden de las dos entregas pendientes. Se hizo una consulta sin acierto de caché. La demora manual de tres minutos afectó a ambas opciones porque el reporte no identificaba un tramo vial que excluir.

**Corrección y resultado parcial.** El comparador ahora distingue un empate de un cambio de distancia o tiempo. Las ocho pruebas focalizadas y la compilación web aprobaron. Queda por verificar el texto corregido en la web principal después de desplegarlo.

**Aprendizaje.** La factibilidad, la aprobación y el ahorro estimado son decisiones diferentes. La comparación debe usar el mismo tramo y declarar los supuestos de cálculo. [Cálculo y captura del caso real](../evidencias/20261109-validacion-danleo/CIERRE_DANLEO_20261109.md).

### R3-09. La recuperación de Android tras desconectarse quedó sin confirmar

**Problema y efecto.** Al quitar el modo avión, una lectura a la API agotó el tiempo de espera. La prueba demostró que se conservaron la sesión y la última consulta durante la desconexión. La causa del tiempo de espera posterior sigue por determinar.

**Cómo se investigó y qué se comprobó.** Se retomó el checkpoint con el acuse de la versión 2 y dos entregas ya guardadas. Se confirmó la tercera desde Android y se compararon las respuestas de API antes y después del reinicio. Persistieron el acuse 2, el historial, las tres entregas únicas y la fecha de la primera. La instalación y el arranque de la APK debug se verificaron en el emulador.

**Resultado parcial y aprendizaje.** La entrega y su persistencia quedaron comprobadas. Para acreditar reconexión se necesita una lectura fresca de la API que coincida con el estado persistido. La consulta de una pantalla guardada solo acredita continuidad local. [Capturas Android y persistencia](../evidencias/20261109-validacion-danleo/CIERRE_DANLEO_20261109.md).

## ¿Qué estamos haciendo bien?

### Resultados verificados del incremento

| Corte | Resultado comprobado | Evidencia |
| --- | --- | --- |
| 04/11 · SonarQube | Quality Gate OK y 90,9 % de cobertura combinada backend. | [Análisis y alcance](../evidencias/20261104-cierre/SONARQUBE_ACTUAL.md) |
| 08/11 · Backend | 127 pruebas aprobadas y 90,88 % de cobertura combinada. | [Regresión y fecha](../evidencias/20261109-validacion-danleo/CIERRE_DANLEO_20261109.md) |
| 09/11 · Flutter | 83 pruebas aprobadas y compilación web correcta. La publicación del texto del comparador quedó pendiente. | [Resultados y límites](../evidencias/20261109-validacion-danleo/CIERRE_DANLEO_20261109.md) |

La tabla siguiente corresponde al corte histórico del **30/10/2026**.

| Verificación | Resultado |
|---|---:|
| Pruebas backend aprobadas | **94**, sin fallos ni errores en el JUnit revisado |
| Pruebas Flutter aprobadas en la ejecución registrada | **58** |
| Cobertura backend local, combinando líneas y ramas | **91,39 %** |
| Cobertura informada por SonarQube | **91,4 %** |
| Quality Gate | **APROBADO / OK** |
| Bugs detectados por SonarQube | **0** |
| Vulnerabilidades detectadas | **0** |
| Code smells | **0** |
| Security hotspots | **0** |
| Incidencias abiertas | **0** |
| Duplicación | **0,0 %** |
| Seguridad, fiabilidad y mantenibilidad | **A / A / A** |

**Evidencia local:** [coverage.xml](../evidencias/20261030/coverage.xml) y [test-results.xml](../evidencias/20261030/test-results.xml). El XML registra 1.641 de 1.743 líneas ejecutables cubiertas y 345 de 430 ramas cubiertas. El porcentaje combinado es `(1641 + 345) / (1743 + 430) × 100 = 91,394385… %`, presentado como 91,39 %.

**Evidencia SonarQube:** [informe del análisis](../evidencias/20261030/SONARQUBE.md) y [resultado estructurado](../evidencias/20261030/sonar_resultado.json); [proyecto ecologisticas](http://localhost:9000/dashboard?id=ecologisticas), finalizado el **30/10/2026 a las 11:45:51, hora de Lima**. Identificador de análisis: `aaabf7bf-fe6c-43be-b38d-8e41ba8eb4e3`.

El 91,4 % es cobertura de pruebas, no una nota sobre la calidad global. SonarQube evaluó backend Python y Dockerfile con perfiles Sonar way core. Flutter tiene sus verificaciones separadas; estos resultados no acreditan una APK validada ni ausencia absoluta de vulnerabilidades. La API del gate devolvió estado OK con la lista de condiciones vacía; el objetivo de cobertura superior al 80 % se comprueba mediante la métrica real.

Los resultados pertenecen al incremento técnico probado en la aplicación de desarrollo. Antes de publicar se debe comprobar que las fuentes copiadas a PFA coincidan con esa versión. Esta corrección documental no sustituye esa comprobación ni representa una nueva ejecución de pruebas.

También se mantuvieron prácticas útiles: PostgreSQL temporal para las pruebas, permisos comprobados en el servidor, conservación de datos mediante migraciones y separación entre propuesta y confirmación.

## ¿Qué podemos hacer mejor?

### Personas

Separar programación, comprobación y aceptación. El responsable debe revisar los resultados y explicar sus límites antes de declarar una historia terminada. Las pruebas aprobadas no sustituyen la aceptación del sprint.

### Relaciones

Preparar para la revisión un caso válido, un rechazo controlado y una confirmación. Registrar con fecha las observaciones realmente recibidas y la acción acordada, sin atribuir opiniones al profesor que no estén documentadas.

### Procesos

Relacionar cada resultado con su versión, fecha y evidencia. Comprobar la correspondencia entre la aplicación probada y la copia de entrega. El ensayo sintético de 150 pedidos y 15 equipos verificó factibilidad en aproximadamente ocho segundos de cálculo; no sustituye una medición completa con base de datos, proveedor vial y red.

### Herramientas

Mantener las pruebas de permisos, concurrencia, ventanas y distribución adaptable. Conservar los informes originales y revisar la configuración antes de usar SonarQube. Las credenciales deben gestionarse localmente y quedar fuera de documentos, capturas y repositorios.

## Acciones a realizar y prevención

Los compromisos siguientes son propuestas de seguimiento. El plazo de cada acción se fija por el hito en que debe verificarse.

| Problema de origen | Compromiso correctivo y preventivo | Responsable | Fecha objetivo propuesta | Indicador verificable |
|---|---|---|---|---|
| R3-01/R3-02: aceptar una ruta sin comprobar toda la operación | Mantener casos GOLD, felices, infelices y de borde; comprobar estado final y restricciones, no solo el código HTTP | Jordy | Antes de aceptar el próximo cambio de la capacidad | Todos los pedidos aparecen una sola vez; los rechazos no generan asignaciones parciales |
| R3-03: revisión visual centrada en escritorio | Ejecutar el flujo en tres tamaños y ambos temas después de modificar la interfaz | Jordy | Antes de aceptar el próximo cambio de la capacidad | Seis combinaciones aprobadas sin desbordamientos |
| R3-04: responsabilidades de configuración mezcladas | Revisar recursos declarados y archivos de la compilación en cada entrega | Jordy | Antes de distribuir el próximo artefacto Web | Ninguna clave del servidor aparece en el artefacto Web |
| R3-05: consultas dentro del recorrido de cada registro | Conservar la prueba de cantidad de consultas y repetirla al modificar la serialización | Jordy | Antes de aceptar el próximo cambio de la capacidad | Cuatro SELECT en los casos de una y cuatro rutas del ensayo, sin autenticación |
| R3-06/R3-07: resultados difíciles de identificar o demostrar | Comprobar clave, fecha, analysisId, cobertura y versión probada antes de cerrar el informe | Jordy | Antes de publicar el próximo resultado | Cada cifra tiene evidencia identificable y la copia de entrega coincide con las fuentes probadas |
| Alcance documental y Jira por conciliar | Confirmar EHAPP-13 / US-005, fechas y correspondencia de IDs históricos antes de contabilizar aceptación | Jordy | Antes de registrar aceptación formal | Ninguna historia ni SP se declara aceptado sin respaldo del compromiso y su revisión |
| R3-08 · El color podía sugerir ahorro con métricas iguales | Verificar en la web publicada el empate y el caso con tiempo y distancia en sentidos distintos | Jordy | Antes de demostrar el comparador actualizado | El empate muestra diferencia cero y cada diferencia se rotula con su unidad |
| R3-09 · La lectura posterior a modo avión agotó su tiempo | Registrar tiempos y respuestas de una consulta fresca después de reconectar. Repetir con la segunda cuenta y comprobar el estado de las entregas | Jordy | Antes de declarar cerrada la validación Android | Lectura nueva exitosa, misma versión y entregas persistidas, sin repetir escrituras |
| Geografía · La validación admitía ubicaciones ajenas al área | Repetir aceptación con un punto válido, uno de borde y otro fuera de la zona, desde el formulario y la API | Jordy | Antes de integrar cambios en mapas o geocodificación | Web y API coinciden en los tres casos y la API rechaza operaciones fuera de zona |
| Entorno · Copiar fuentes no demostraba qué compilación se servía | Registrar versión fuente, imagen y entorno de cada demostración. Conservar un checkpoint con el último estado confirmado cuando se interrumpa la prueba | Jordy | Antes de la próxima promoción y en cada interrupción | La web servida corresponde al build registrado y la reanudación conserva los acuses y entregas |

## Seguimiento

Una acción se cierra cuando su indicador tiene evidencia, no solo por marcarla como realizada. La siguiente revisión debe comprobar la conservación de las correcciones, la correspondencia de las fuentes de entrega y los asuntos que siguen requiriendo validación: compromiso de Jira, aceptación, accesibilidad integral y rendimiento completo del flujo. El acuse y la persistencia están comprobados. Quedan pendientes la reconexión Android, la segunda cuenta en emulador, la validación en teléfono físico y el texto del comparador en la web publicada. El responsable de seguimiento es Jordy.

## Aprendizajes de la corrección funcional — 02/11/2026

| Problema comprobado | Qué corregimos y cómo | Qué aprendimos | Compromiso preventivo propuesto |
|---|---|---|---|
| Mensaje de rechazo fuera de vista después de Generar | Reubicamos feedback y enfocamos resultado/error; añadimos regresiones de visibilidad a 360 px. | Una API correcta puede parecer que no funciona si la interfaz no comunica el resultado cerca de la acción. | Jordy: incluir visibilidad de error y recuperación en cada caso de aceptación de formularios extensos. |
| ACTIVO confundido con disponible y rutas históricas sin horario | Diagnóstico de rutas bloqueantes antes de calcular, con IDs buscables; mantuvimos la validación del servidor. | No se puede deducir disponibilidad ni inventar una duración a partir del estado ACTIVO. | Jordy: preparar un dataset QA con turnos/orígenes/ventanas y regularizar cada registro histórico con datos reales. |
| Pedidos de octubre frente a salida de noviembre | Aviso de ventana incompatible y acción explícita para elegir el inicio de las ventanas seleccionadas. | Un dataset reutilizado puede invalidar una demostración aunque el algoritmo sea correcto. | Jordy: revisar fechas y capacidad antes de cada exposición; conservar pruebas históricas como históricas. |
| Consulta de rutas sin operación del repartidor | Conectamos inicio, entrega secuencial e incidencia a la API y transacciones existentes; registramos hora/autor e idempotencia. | Dos pantallas conectadas al mismo dato no acreditan por sí solas el ciclo operativo completo. | Jordy: demostrar ADMIN → REPARTIDOR → ADMIN y distinguir la integración adicional US-010/S5 del compromiso US-005/S3. |
| Cambio de dirección no detectado al confirmar | Incluimos dirección/referencia en la huella y añadimos prueba que exige 409. | Hay que verificar también los campos descriptivos que usa la persona para entregar, no solo las coordenadas. | Jordy: todo nuevo dato usado por una propuesta debe estar en su snapshot y su regresión de cambio concurrente. |
| Vista previa con null y decimales extensos | Adaptamos el contrato de presentación, conservamos datos de origen y redondeamos únicamente la vista. | Reutilizar un componente requiere verificar todos sus campos y estados reales. | Jordy: revisar propuesta, ruta guardada y datos ausentes en navegador antes de dar por cerrada la interfaz. |
| Tres fallos por mezclar configuración QA con suite | Separamos CORS y credenciales demo del entorno de pruebas; mantuvimos las aserciones y repetimos la suite. | El aislamiento incluye configuración, además de base de datos. | Jordy: guardar comandos, entorno y resultados de una ejecución final sobre fuentes estables. |
| Build Android con recursos excesivos | Reintentamos con Gradle de 2 GiB, dos trabajadores y emulador reducido; la APK debug compiló. | La compilación y la ejecución deben medirse por separado; no atribuir un OOM sin evidencia. | Jordy: conservar límites reproducibles y revisar la prueba nativa en ANDROID.md antes de afirmar validación. |

Estos son hallazgos técnicos y compromisos propuestos, no una reunión ni acuerdos inventados. Resultados nuevos y porcentaje exacto (archivo histórico local del corte de Lima) · Registro detallado de defectos (archivo histórico local del corte de Lima).

## Ampliación de tráfico e incidencias — verificación nocturna del 02/11/2026

Esta sección analiza el incremento adicional solicitado sobre las dependencias del Sprint 3. No reasigna historias ni presenta una reunión inventada.

| Problema observado | Solución aplicada | Aprendizaje concreto | Compromiso preventivo propuesto para Jordy |
|---|---|---|---|
| OSRM dibujaba calles, pero no aportaba congestión observada | Diferenciamos matriz vial, aproximaciones zonales y reportes manuales. El motor evalúa los tramos según la hora, no solo su distancia. | Un mapa detallado no demuestra tráfico en vivo ni permite inferir la congestión de todas las calles. | Antes de activar otro proveedor, verificar fuente, cobertura, cuota, fecha del dato y licencia; adjuntar prueba de indisponibilidad. |
| Recalcular podía invalidar la operación ya realizada | Propuesta separada, snapshot completo, comprobación de cambios y aprobación con bloqueo transaccional; las entregas completadas conservan su fila/hora. | Una reoptimización debe tratar también el estado persistente, no únicamente producir otra lista de paradas. | Mantener regresión que complete una entrega durante el cálculo y exija rechazo de la propuesta desactualizada. |
| Enviar una ruta podía confundirse con haberla recibido | Bandeja durable, versión vigente/recibida separadas, acuse explícito e idempotente y bloqueo de entregas con versión incompatible. | Una notificación emitida no acredita recepción ni lectura del nuevo recorrido. | Verificar versión pendiente antes del acuse y conservar evidencia de recuperación por consulta; ampliar a pérdida real de señal móvil. |
| Dos confirmaciones administrativas podían competir | Bloqueos en orden estable, huella de recursos/pedidos/tráfico y validación de versión. | La validación frontend no evita escrituras concurrentes. | Conservar el caso concurrente 200/409 y prohibir cambios parciales o duplicación de pedidos. |
| La base de pruebas retuvo una restricción de la migración en desarrollo | Reconstrucción del esquema exclusivamente en la base desechable protegida y repetición completa de migraciones/pruebas. | Un entorno antiguo puede generar fallos que no describen las fuentes actuales. | Exigir el guard de host/nombre QA y guardar resultados de una ejecución limpia, sin tocar bases funcionales. |
| Refresco automático invadió un formulario interno | El análisis detectó los identificadores incorrectos; se preservó el formulario y se acotaron temporizadores a listas/tablero. | Sincronizar no debe borrar ni reemplazar una edición en curso. | Ejecutar análisis antes de compilar y probar campos abiertos además de vistas de consulta. |
| Un fondo de mapa falló durante la prueba | Se conservó geometría/datos, se comunicó el fallo y el reintento recuperó las calles. | La caída de tiles es distinta a la falta de geometría vial y necesita recuperación visible. | Mantener ambas pruebas de fallo separadas y revisar el proveedor antes de operación sostenida. |
| Era fácil atribuir al sistema un ahorro o rendimiento no demostrado | Se mostró diferencia cero cuando correspondía y se separaron benchmark CPU, cobertura local y Sonar histórico. | Una cifra solo es útil si se conoce su denominador, entorno y alcance. | Conservar HTML/XML/JUnit, dataset y tiempos; acreditar el flujo completo antes de cerrar EN-002. |

Ejecución, cobertura y problemas reales (archivo histórico local del corte de Lima) · Acciones pendientes verificables (archivo histórico local del corte de Lima).

## Corrección territorial y verificación — 03/11/2026

### Problemas, solución y aprendizaje de esta corrección

| Problema comprobado | Solución aplicada y comprobación | Aprendizaje y compromiso preventivo |
|---|---|---|
| Cambios guardados en stage podían confundirse con versión principal desplegada | Inventario SHA de26 fuentes, recuperación de QA, sincronización guardada y separación explícita de principal 8080 | Conservar huellas, respaldo y ruta del build; no anunciar despliegue por copiar fuentes |
| El geocodificador y fixtures admitían ciudades ajenas | Búsqueda/reversa y entradas restringidas a envolvente Huancayo aprobada; casos negativos de Lima y límites | Validar también en servidor y antes del motor; revisar destino confirmado, no solo texto de dirección |
| Registros históricos no debían moverse para parecer locales | Consulta preservada, aviso fuera de zona y operaciones bloqueadas | Mantener procedencia y evidencia; corregir reglas futuras sin falsear coordenadas del pasado |
| Quedaba permitido cambiar horario de una ruta histórica exterior | Guard de área en horario y prueba409;23 pruebas pertinentes y127 de regresión aprobadas | Revisar cada acción de escritura del mismo recurso, no solo iniciar/entregar |
| No había fundamento para usar horas punta de Lima | Catálogo histórico El Tambo 2015 con franja08:00–09:00, sinfactor/díasautomáticos; factor 1,2 QA identificado como sintético | Investigar fuente local y fecha; no extrapolar aforo a duración ni historia a tráfico2026 |
| Enviar versión nueva podía confundirse con recibirla | Web mostró versión 2/recibida 1 antes del acuse y2/2después; historial persistió tras reinicio | Exigir acuse efectivo y probar recuperación antes de continuar entregas; ampliar a GOLD móvil |
| Era posible comunicar ahorro sin mejora real | Se conservó comparación4,04 km/11,10 min contraigualvalor, diferencia 0 | Informar factibilidad y recepción por separado de ahorro; no modificar pruebas para elevar cifras |

La primera entrega permaneció con fecha original; las tres se finalizaron sin duplicar pedidos. La cobertura actual90,88 % corresponde al backend y no reemplaza el Sonar histórico91,4% ni acredita seguridad absoluta. [Resultados, comandos y pruebas](../evidencias/20261103-huancayo/RESULTADOS.md). [Compromisos de cierre](../evidencias/20261103-huancayo/PENDIENTES.md).

## Retrospectiva de la estabilización del Sprint 3 — 03/11/2026

Reflexión técnica sobre hechos observados; no se inventa una reunión ni acuerdos de otras personas.

| Problema y causa | Cómo lo corregimos y comprobamos | Qué aprendimos y cómo evitar su repetición |
|---|---|---|
| El mapa reutilizaba controlador/proveedor después de desmontarse en una lista; Android mostró errores de ciclo de vida | Se aisló el mapa en un componente con recursos propios, estado conservado y callbacks posteriores al frame. Pasó la regresión de desplazamientos/geometría/liberación y la operación real | Desplazarse por el formulario también cambia el ciclo de vida. Antes de integrar cambios del mapa, ejecutar su prueba y abrir/cerrar/desplazar el detalle en móvil. |
| Las insignias se desbordaron 76/54 px con texto ampliado | Texto flexible; casos claro/oscuro a 360/768/1440 y texto al 200 % | No basta revisar escritorio a escala normal. Incluir el caso de texto ampliado en cada modificación de controles compactos. |
| La interrupción dejó un recorrido iniciado unas trece horas antes, fuera de jornada | El servidor rechazó el replan. Se conservó esa entrega/incidencia y se creó otro caso QA con horarios vigentes, sin aumentar límites ni retroceder el reloj | Una prueba interrumpida puede dejar de ser válida por negocio. Comprobar turno, jornada consumida y ventanas antes de la demostración; conservar el rechazo como evidencia. |
| La señal inicial del emulador podía estar fuera de Huancayo | Se exigió una fijación nueva de GNSS, se inyectó únicamente el punto público del Parque y se mantuvo la aserción geográfica estricta | Una coordenada no debe sustituirse silenciosamente para aprobar. Identificar emulación, precisión y fecha, y separar esa prueba de GPS físico. |
| El test buscaba controles fuera de pantalla o antes de estar habilitados; una edición también alteró su codificación | Se corrigieron desplazamiento, espera de carga/acciones habilitadas y UTF-8. Los reintentos preservaron acuse, inicio y entrega; la continuación aprobó sin reiniciar datos | El fallo puede pertenecer al test o al producto: comparar registros HTTP y PostgreSQL antes de corregir. Usar esperas observables, formato/análisis y verificaciones idempotentes. |
| Copiar stage no garantizaba que 8080 usara esos cambios | Se verificaron SHA de fuentes en D/PFA y se promovió un build principal con respaldo/reversión. Se repitió la consulta tras reiniciar API | Registrar carpeta servida, versión y respuesta real. No anunciar despliegue solo por copiar código. |

**Qué salió bien:** se conservaron datos y evidencias; se separó la base QA; se comprobó el acuse efectivo antes de continuar entregas; la primera entrega mantuvo su fecha y no se inventó ahorro.

**Mejora y compromisos propuestos para Jordy:** antes de la próxima integración, ejecutar las regresiones de mapa/adaptación, comprobar disponibilidad y horarios del fixture, registrar versión enviada/recibida antes y después del reinicio, y adjuntar la medición de cobertura de la misma versión. Revisar cada resultado del test contra PostgreSQL sin reiniciar datos para obtener un pase. Confirmar estos compromisos en la retrospectiva real.

**Resultado:** 127 backend, 81 Flutter, continuación Android aprobada, cobertura combinada backend 90,88 %, Bandit/pip-audit sin hallazgos. No hay nuevo Sonar: el 91,4 % pertenece al corte histórico. [Pruebas y evidencia](../evidencias/20261103-estabilizacion/RESULTADOS.md) · [Acciones externas](../evidencias/20261103-estabilizacion/PENDIENTES.md).

## Aprendizajes del contraste de cierre — 04/11/2026

| Problema real de cierre | Solución aplicada | Aprendizaje y compromiso preventivo propuesto |
|---|---|---|
| La planificación anterior y Jira utilizaban números US, fechas y alcances diferentes; podían mezclarse 22SP con13SP | Lectura autenticada actual, exportación mínima, claves EHAPP estables y adenda que identifica los alias anteriores como LEG-V1.2. Se preserva el historial. | Jordy: antes de preparar una exposición/cierre, contrastar el compromiso real y enlazar una matriz vigente; no renumerar historias antiguas ni sumar SP de baselines distintas. |
| El resultado funcional podía confundirse con conformidad completa de la inspección académica | Se completó un flujo Web principal nuevo, se verificaron persistencia/permisos y se separaron Sonar/WCAG/OWASP y distribución móvil en estados concretos. | Jordy: revisar la lista de criterios docentes antes de declarar cierre; adjuntar evidencia por criterio y mantener pendientes los no comprobados. |
| Un archivo llamado release podía seguir firmado con debug | Se inspeccionó Gradle y se verificó la firma de la APK existente; no se generó una supuesta release sin firma/configuración de entrega. | Antes de distribuir, comprobar certificado, URL de API y dispositivo objetivo; compilar no equivale a validar una distribución. |
| Se podía repetir la regresión estable sin aportar evidencia nueva | Se compararon 288 destinos de código y se comprobaron JUnit/XML/huella APK. Se ejecutó solo el flujo Web y permisos/persistencia que aportaban el cierre pendiente. | Repetir las suites cuando cambien los componentes o exista un fallo nuevo; conservar fecha y alcance de cada medición, sin anunciarla como ejecución nueva. |

Estos compromisos se proponen para confirmación del responsable; no se atribuyen a una ceremonia inexistente. Se conserva el resultado 127/81 y 90,88 % backend y la validación Android anterior. [Dictamen, evidencia y acciones para cerrar](../evidencias/20261104-cierre/INFORME_CIERRE_SPRINT3.md).

## Resultado SonarQube — 04/11/2026, 08:35 Perú

Proyecto **ecologisticas2.1** confirmado por Jordy. Procesamiento SUCCESS y **Quality Gate OK/PASSED**; cobertura backend **90,9 %**, cero vulnerabilidades/bugs/code smells/hotspots, duplicación0,0 %, perfiles Sonar way core. El bloqueo de análisis quedó resuelto; no se atribuye esta cifra a Flutter ni se declara cierre académico total. Los intentos sobre la clave antigua no alteraron permisos o gate. [Resultado, analysisId y límites](../evidencias/20261104-cierre/SONARQUBE_ACTUAL.md).

## Aprendizajes de consolidación del Sprint 3 — 04/11/2026

| Problema observado | Corrección comprobada | Qué aprendimos y acción preventiva propuesta |
| --- | --- | --- |
| La aplicación podía depender de un build servido desde carpetas temporales y coexistían varias versiones de servidores | Se compilaron imágenes desde D y se activó un Compose con postgres/api/web. Inspect confirma que API/web no montan stage ni el workspace; los recursos protegidos de otros proyectos no cambiaron | Publicar una versión exige identificar la fuente, imagen y carpeta servida. Antes de la siguiente entrega, registrar esas tres identidades y comprobar la salud después del arranque. |
| Los datos QA podían confundirse con registros operativos | El responsable confirmó que todos eran pruebas. Se creó otra base operativa vacía, sin borrar la histórica; principal y QA se restauraron con hashes idénticos | Separar demostración de operación y verificar la recuperación antes de limpiar. En el siguiente corte, identificar la base de cada prueba y prohibir fixtures en la base operativa. |
| La guía aún mostraba claves demo y arrancaba un servidor Flutter adicional | Se corrigió el arranque al Compose final, se generó una clave ADMIN privada y el login real mostró el panel vacío | Código correcto con instrucciones antiguas produce errores de uso. Revisar arranque, credenciales y guía contra el mismo entorno antes de entregar. |
| Un porcentaje sin informe reproducible es difícil de defender | Se ejecutó la regresión en la imagen consolidada y PostgreSQL aislado; se guardaron XML, HTML, JUnit y logs en PFA | Citar siempre el alcance y numerador/denominador: 2261/2410 líneas y 478/604 ramas, combinadas 90,88 %. Conservar el reporte del corte, sin extrapolar a Flutter ni repetir porcentajes históricos. |

Estas acciones son compromisos preventivos propuestos al responsable, no acuerdos de una reunión inventada. Se mantienen como límites la nueva validación Android/recorrido completo contra el entorno limpio, teléfono físico, release y aceptación académica. El Sonar previo del mismo día conserva su resultado; no se ejecutó otro con credenciales expuestas. [Resultados, pruebas y cobertura HTML/XML](../evidencias/20261104-consolidacion/RESULTADOS.md).
