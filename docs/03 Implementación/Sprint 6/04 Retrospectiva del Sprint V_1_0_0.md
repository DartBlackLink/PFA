# Retrospectiva del Sprint 6

**Proyecto:** EcoLogística Huancayo. **Responsable:** Jordy Steve Chancasanampa Torres. **Corte del trabajo revisado:** 14/11/2026. **Actualización documental:** 16/11/2026. **Versión del contenido:** 1.1.0.

Esta retrospectiva recoge lo aprendido durante el desarrollo y las pruebas del alcance del sprint. Las acciones siguientes orientan la próxima revisión del trabajo.

## ¿Qué aprendimos?

Aprendimos que guardar el nombre de una persona en un pedido no resolvía la gestión de sus preferencias. Hacía falta seleccionar al mismo cliente y conservar su relación con los pedidos. Por eso añadimos su gestión y la selección por identificador.

También aprendimos a comprobar qué base usa realmente la aplicación antes de respaldarla. El primer respaldo correspondía a una base heredada; al revisar la conexión de FastAPI identificamos la base operativa y generamos el respaldo correcto antes de la migración.

## ¿Qué estamos haciendo bien?

Comprobamos el registro de un cliente, sus preferencias y su selección al crear un pedido. También revisamos la baja lógica y la reactivación sin perder esa información. Las pantallas nuevas se probaron a 360 píxeles en ambos temas, y el control de integridad confirmó que los datos originales se conservaron.

## ¿Qué podemos hacer mejor?

### Personas

Debemos explicar con claridad los indicadores ambientales. La equivalencia configurada usa un factor y una fuente de referencia; no significa que se haya realizado una compensación de carbono. Comprender esa diferencia nos ayuda a usar términos correctos en la pantalla, el PDF y la exposición.

### Relaciones

La documentación y la demostración deben contar lo mismo. Al revisar el proyecto con el docente, debemos enseñar cómo una preferencia queda asociada al cliente y cómo se utiliza al registrar un pedido. Las observaciones que recibamos deben quedar vinculadas a ese caso para saber qué corregir y cómo comprobarlo después.

### Procesos

Antes de una migración debemos comprobar la conexión activa y validar que el respaldo corresponda a esa base. En los formularios, debemos revisar desde el principio si estamos reutilizando un registro o creando uno nuevo. Ambas comprobaciones evitan trabajar sobre el destino equivocado o perder la relación entre los datos.

### Herramientas

Las primeras pruebas de widgets fallaron por un control fuera del área visible y por temporizadores pendientes en el montaje de prueba. Corregimos el desplazamiento y la preparación asíncrona del test. Esto nos enseñó a investigar la causa antes de modificar la interfaz: un fallo de la prueba no siempre es un fallo de la web. Después completamos la revisión en un navegador real.

### Acciones a realizar

| ID | Compromiso de mejora | Cuándo aplicarlo | Cómo comprobarlo |
|---|---|---|---|
| R6-A01 | Comprobar que crear o editar un pedido conserva el cliente seleccionado. | Al modificar el formulario de pedidos. | Se mantiene el identificador y se rechaza la selección de un cliente inactivo. |
| R6-A02 | Revisar factor, unidad, fuente y explicación de la equivalencia ambiental. | Antes de mostrar un indicador nuevo o cambiar su parámetro. | El cálculo puede explicarse y, si falta un dato, se muestra como no disponible. |
| R6-A03 | Confirmar la base activa y comprobar el respaldo antes de migrar. | Antes de cada migración. | El respaldo corresponde a la conexión de la aplicación y se registra el control de integridad. |
| R6-A04 | Revisar los formularios con teclado y lector de pantalla. | Antes de cerrar la revisión de accesibilidad. | Se registran los resultados por tarea y se corrigen los problemas encontrados. |

**Responsable de seguimiento:** Jordy. Estas acciones se revisarán en el siguiente trabajo relacionado; su cumplimiento se registrará cuando se realicen.

Los problemas y sus correcciones se detallan en el [registro de impedimentos](02%20Registro%20de%20Impedimentos%20V_1_0_0.md). Los [resultados y evidencias](../evidencias/20261114-desarrollo-integral/RESULTADOS.md) respaldan las comprobaciones mencionadas.

[Índice](README.md)
