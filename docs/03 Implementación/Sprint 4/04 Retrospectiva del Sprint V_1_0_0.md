# Retrospectiva del Sprint 4

**Proyecto:** EcoLogística Huancayo. **Responsable:** Jordy Steve Chancasanampa Torres. **Corte del trabajo revisado:** 14/11/2026. **Actualización documental:** 16/11/2026. **Versión del contenido:** 1.2.0.

Esta retrospectiva recoge lo aprendido durante el desarrollo y las pruebas del alcance del sprint. Las acciones siguientes orientan la próxima revisión del trabajo.

## ¿Qué aprendimos?

Aprendimos que ver una ruta dibujada en el mapa no era suficiente para darla por correcta. Al revisar las asignaciones manuales encontramos que faltaban las horas estimadas de llegada y los indicadores de combustible y CO₂. También vimos que cambiar la salida podía dejar una entrega fuera de su horario, aunque el recorrido siguiera apareciendo en pantalla.

Al corregirlo entendimos que debemos revisar el recorrido, los tiempos y los datos guardados como una sola operación. Ahora la validación considera tanto la llegada como el tiempo necesario para atender cada entrega.

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

Las pruebas automáticas ayudaron a revisar horarios e indicadores sin depender solo del mapa. La medición con el proveedor vial también fue útil, aunque se hizo con una sola semilla y tres destinos públicos repetidos. Debemos ampliar los casos antes de sacar conclusiones generales sobre el rendimiento.

### Acciones a realizar

| ID | Compromiso de mejora | Cuándo aplicarlo | Cómo comprobarlo |
|---|---|---|---|
| R4-A01 | Revisar llegada, atención, turno y cruces de horario al cambiar una asignación. | Antes de integrar cambios en rutas u horarios. | El caso inválido se rechaza y la ruta anterior conserva sus datos. |
| R4-A02 | Comprobar que cada indicador calculado se guarda y llega a la pantalla. | Al agregar o modificar un indicador. | Se contrasta el valor calculado, la respuesta API y lo mostrado en la web. |
| R4-A03 | Revisar las respuestas esperadas del script antes de medir tiempos. | Antes de la siguiente medición. | El script acepta el 201 documentado y conserva los resultados completos. |
| R4-A04 | Ampliar la prueba de rendimiento siguiendo el protocolo acordado. | Antes de cerrar la validación de rendimiento. | Quedan registrados los distintos casos, las semillas y los tiempos obtenidos. |

**Responsable de seguimiento:** Jordy. Estas acciones se revisarán en el siguiente trabajo relacionado; su cumplimiento se registrará cuando se realicen.

Los problemas y sus correcciones se detallan en el [registro de impedimentos](02%20Registro%20de%20Impedimentos%20V_1_0_0.md). Los [resultados y evidencias](../evidencias/20261114-desarrollo-integral/RESULTADOS.md) respaldan las comprobaciones mencionadas.

[Índice](README.md)
