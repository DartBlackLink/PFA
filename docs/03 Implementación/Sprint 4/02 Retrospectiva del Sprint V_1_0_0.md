# Retrospectiva del sprint

**Nombre del Proyecto:** EcoLogística Huancayo.

**Líder del Proyecto:** Chancasanampa Torres, Jordy Steve.

**Sprint:** 4. **Corte del trabajo revisado:** 14/11/2026. **Actualización documental:** 18/11/2026. **Versión del contenido:** 1.4.0.

Esta retrospectiva recoge lo aprendido durante el desarrollo y las pruebas del alcance del sprint. Las acciones siguientes orientan la próxima revisión del trabajo. Se conservan las respuestas revisadas el 16/11 y la estructura solicitada; esta actualización no atribuye una nueva reunión ni acuerdos de terceros.

## ¿Qué aprendimos?

Al publicar el 19/11 aprendimos que una aplicación que funciona en nuestro equipo puede necesitar otro empaquetado en el hosting. Wasmer no tenía varias ruedas de nuestras versiones; comprobamos las alternativas en su registro y las auditamos en una lista separada, sin tocar el entorno de desarrollo. También aprendimos a revisar el log de ejecución: el build terminó bien, pero el servidor devolvía 500 por el comando con `&&` y por variables que no se habían guardado. Lo corregimos en el panel y no lo dimos por resuelto hasta iniciar sesión y terminar una entrega desde la URL pública.


Aprendimos que ver una ruta dibujada en el mapa no era suficiente para darla por correcta. Al revisar las asignaciones manuales encontramos que faltaban las horas estimadas de llegada y los indicadores de combustible y CO₂. También vimos que cambiar la salida podía dejar una entrega fuera de su horario, aunque el recorrido siguiera apareciendo en pantalla.

Al corregirlo entendimos que debemos revisar el recorrido, los tiempos y los datos guardados como una sola operación. Ahora la validación considera tanto la llegada como el tiempo necesario para atender cada entrega.

Al ampliar las pruebas apareció algo que la primera medición no mostraba: 150 pedidos podían repetir solo tres lugares y aun así generar muchas consultas al proveedor. Una semilla falló en frío, aunque otras pasaban con caché. Aprendimos a conservar el fallo, separar el tiempo del motor del tiempo vial y revisar las llamadas que realmente estábamos haciendo. No cambiamos el objetivo para conseguir un aprobado.

También comprobamos que tener el health en OK no demostraba que la reoptimización funcionara. El caso completo encontró la solicitud de una sola coordenada, que OSRM no admite. Corregimos el protocolo y comprobamos que la entrega ya registrada siguiera intacta.

## ¿Qué estamos haciendo bien?

Fue útil comprobar las rutas con el mapa de Huancayo y revisar después lo que había quedado guardado. Así pudimos detectar diferencias que no se veían al abrir la pantalla. También conservamos los registros anteriores y añadimos pruebas para comprobar que un horario inválido se rechace sin cambiar la ruta existente.

## ¿Qué podemos hacer mejor?

### Personas

Necesitamos comprender mejor los datos que mostramos antes de dar una función por terminada. Por ejemplo, debemos poder explicar de dónde sale la hora estimada de llegada y qué significa que una ruta no tenga un indicador. Revisar esas preguntas durante el desarrollo nos habría ayudado a detectar antes los campos que faltaban.

### Relaciones

Al presentar el avance al docente, conviene mostrar un caso válido y otro que el sistema rechace, además del mapa. Esto permite explicar las restricciones y recibir observaciones concretas sobre lo que todavía debemos mejorar. Para rendimiento, debemos acordar qué cantidad y variedad de pruebas se espera como evidencia.

### Procesos

Nos faltó revisar el contrato de la API antes de medir el rendimiento: el script esperaba una respuesta 200, pero crear una propuesta devuelve 201. Corregimos el script y conservamos la medición original. En la siguiente ejecución comprobaremos primero qué respuesta debe devolver cada operación para no confundir un error de la prueba con un fallo del sistema.

### Herramientas

Las pruebas automáticas ayudaron a revisar horarios e indicadores sin depender solo del mapa. La medición inicial tenía una sola semilla. Ahora ejecutamos cinco semillas para 10, 50 y 150 pedidos, conservando también el caso fallido anterior. Los destinos siguen siendo tres lugares repetidos: debemos decirlo al exponer y no generalizar los tiempos a toda la ciudad.

Al ejecutar las suites juntas también usamos por error el mismo puerto para dos servidores de prueba. Parecía un fallo de la aplicación, pero las peticiones llegaban al servidor equivocado. Separamos los puertos y repetimos la regresión sin modificar sus aserciones. En WebKit verificamos el texto escrito antes de enviarlo y evitamos el atajo Tab que bloqueaba el editor de prueba.

### Acciones a realizar

| ID | Compromiso de mejora | Cuándo aplicarlo | Cómo comprobarlo |
|---|---|---|---|
| R4-A01 | Revisar llegada, atención, turno y cruces de horario al cambiar una asignación. | Antes de integrar cambios en rutas u horarios. | El caso inválido se rechaza y la ruta anterior conserva sus datos. |
| R4-A02 | Comprobar que cada indicador calculado se guarda y llega a la pantalla. | Al agregar o modificar un indicador. | Se contrasta el valor calculado, la respuesta API y lo mostrado en la web. |
| R4-A03 | Revisar las respuestas esperadas del script antes de medir tiempos. | Antes de la siguiente medición. | El script acepta el 201 documentado y conserva los resultados completos. |
| R4-A04 | Ampliar la prueba de rendimiento siguiendo el protocolo acordado. | Antes de cerrar la validación de rendimiento. | Quedan registrados los distintos casos, las semillas y los tiempos obtenidos. |

La revisión de Semana 14 añadió un compromiso: antes de presentar resultados, separar pruebas del servidor, pruebas Flutter, E2E y evaluación con usuarios. Jordy comprobará que cada cifra tenga su informe y fecha; una prueba automática no se usará como puntuación SUS. El seguimiento está en las [acciones de cierre](ACCIONES_PARA_CERRAR_SPRINT4.md).

**Responsable de seguimiento:** Jordy. Estas acciones se revisarán en el siguiente trabajo relacionado; su cumplimiento se registrará cuando se realicen.

Los problemas y sus correcciones se detallan en el [registro de impedimentos](02%20Registro%20de%20Impedimentos%20V_1_0_0.md). Los [resultados y evidencias](../evidencias/20261114-desarrollo-integral/RESULTADOS.md) respaldan las comprobaciones mencionadas.

[Índice](README.md)


[← Volver al README principal](../../../README.md)


**Seguimiento del 18/11:** R4-A04 se ejecutó para cinco semillas y tres tamaños; los 15 casos posteriores a la corrección cumplieron sus umbrales en esta muestra. Se mantiene la mejora de variedad geográfica. Nuevo compromiso: antes de cambiar el ruteo, probar también todas las paradas en una misma coordenada; cuatro regresiones de matriz y el GOLD evitan repetir ese error. Jordy revisará reporte, resultado guardado y causa de cualquier fallo antes de presentarlo como resuelto. Véanse [evidencias](../evidencias/20261118-semana14/RESULTADOS.md). No se atribuye una nueva reunión o aceptación docente.


**Compromiso de publicación:** antes de considerar una versión lista, comprobar el arranque, la lectura real de secretos, login por rol y una escritura persistida; build en verde no basta. Conservar paquetes compatibles separados y no flexibilizar restricciones para adaptar el hosting. [Resultado del 19/11](../evidencias/20261119-despliegue-publico/RESULTADOS.md).
