[Índice de implementación](../README.md) · [README del proyecto](../../../README.md)

# Retrospectiva del Sprint 3

**Proyecto:** EcoLogística — caso académico EcoLogística Lima; interfaz existente Huancayo.

**Responsable:** Jordy Steve Chancasanampa Torres.

**Sprint:** 3. **Versión:** 1.0.0. **Corte técnico:** 30/10/2026.

**Método:** reflexión individual basada en los problemas encontrados al implementar y comprobar el incremento. Se distinguen defectos corregidos, controles preventivos y asuntos que requieren seguimiento. Las acciones futuras son propuestas del responsable, no acuerdos atribuidos a una reunión.

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

## ¿Qué estamos haciendo bien?

### Resultados verificados del incremento

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

Los compromisos siguientes se proponen para el próximo cierre. No se presentan como acuerdos de una reunión ya realizada.

| Problema de origen | Compromiso correctivo y preventivo | Responsable | Fecha objetivo propuesta | Indicador verificable |
|---|---|---|---|---|
| R3-01/R3-02: aceptar una ruta sin comprobar toda la operación | Mantener casos GOLD, felices, infelices y de borde; comprobar estado final y restricciones, no solo el código HTTP | Jordy | 02/11/2026, antes de la entrega | Todos los pedidos aparecen una sola vez; los rechazos no generan asignaciones parciales |
| R3-03: revisión visual centrada en escritorio | Ejecutar el flujo en tres tamaños y ambos temas después de modificar la interfaz | Jordy | 02/11/2026, antes de la entrega | Seis combinaciones aprobadas sin desbordamientos |
| R3-04: responsabilidades de configuración mezcladas | Revisar recursos declarados y archivos de la compilación en cada entrega | Jordy | 02/11/2026, antes de distribuir | Ninguna clave del servidor aparece en el artefacto Web |
| R3-05: consultas dentro del recorrido de cada registro | Conservar la prueba de cantidad de consultas y repetirla al modificar la serialización | Jordy | 02/11/2026, antes de la entrega | Cuatro SELECT en los casos de una y cuatro rutas del ensayo, sin autenticación |
| R3-06/R3-07: resultados difíciles de identificar o demostrar | Comprobar clave, fecha, analysisId, cobertura y versión probada antes de cerrar el informe | Jordy | 02/11/2026, antes de publicar | Cada cifra tiene evidencia identificable y la copia de entrega coincide con las fuentes probadas |

| Alcance documental y Jira por conciliar | Confirmar EHAPP-13 / US-005, fechas y correspondencia de IDs históricos antes de contabilizar aceptación | Jordy | 02/11/2026, antes del cierre | Ninguna historia ni SP se declara aceptado sin respaldo del compromiso y su revisión |

## Seguimiento

Una acción se cierra cuando su indicador tiene evidencia, no solo por marcarla como realizada. La siguiente revisión debe comprobar la conservación de las correcciones, la correspondencia de las fuentes de entrega y los asuntos que siguen requiriendo validación: compromiso de Jira, aceptación, accesibilidad integral y rendimiento completo del flujo.
