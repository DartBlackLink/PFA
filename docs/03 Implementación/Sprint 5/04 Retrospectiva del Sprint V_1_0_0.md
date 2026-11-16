# Retrospectiva del Sprint 5

**Proyecto:** EcoLogística Huancayo. **Responsable:** Jordy Steve Chancasanampa Torres. **Corte del trabajo revisado:** 14/11/2026. **Actualización documental:** 16/11/2026. **Versión del contenido:** 1.1.0.

Esta retrospectiva recoge lo aprendido durante el desarrollo y las pruebas del alcance del sprint. Las acciones siguientes orientan la próxima revisión del trabajo.

## ¿Qué aprendimos?

Aprendimos que generar un PDF en el servidor no completaba la descarga. Nuestro cliente HTTP estaba preparado para leer JSON, así que necesitaba recibir el archivo como bytes y comprobar que realmente fuera un PDF. Esta dificultad nos hizo revisar la función desde el botón hasta el archivo descargado.

Al probar la reoptimización también confirmamos la importancia de separar la aprobación del administrador de la recepción del repartidor. La nueva versión debe tener su confirmación y conservar las entregas que ya se realizaron.

## ¿Qué estamos haciendo bien?

La prueba completa con ambos roles permitió comprobar la continuidad del trabajo: se entregó un pedido, se reportó una incidencia simulada y se completó la entrega restante después de recibir la nueva ruta. Revisar los datos guardados nos ayudó a confirmar que la primera entrega seguía intacta. Con el PDF hicimos algo parecido: lo descargamos y revisamos su contenido y presentación.

## ¿Qué podemos hacer mejor?

### Personas

Debemos revisar también las respuestas de error cuando desarrollamos una descarga. Al principio el trabajo estaba centrado en obtener el archivo; faltaba considerar que el servidor podía responder con un mensaje JSON o una página HTML. Incluir esos casos desde el comienzo reduce las correcciones al final.

### Relaciones

En el flujo entre administrador y repartidor debe quedar claro qué acción corresponde a cada uno. Aprobar una alternativa no significa que el repartidor ya la recibió. Las notificaciones y la confirmación de recepción ayudan a evitar esa confusión; debemos comprobar ambas partes cuando cambiemos este flujo.

### Procesos

La auditoría detectó una versión afectada de `opentelemetry-api`. La actualizamos de 1.45.1 a 1.45.2 y repetimos los controles. Aprendimos que la revisión de dependencias debe formar parte de cada entrega, aunque no hayamos cambiado directamente esa librería.

### Herramientas

Las pruebas de la API y de Flutter nos ayudaron a detectar respuestas que no debían convertirse en un PDF y accesos que el servidor debía rechazar. Nos conviene mantener esas comprobaciones junto a la prueba visual del archivo para no depender únicamente de que el botón responda.

### Acciones a realizar

| ID | Compromiso de mejora | Cuándo aplicarlo | Cómo comprobarlo |
|---|---|---|---|
| R5-A01 | Probar la descarga con un PDF válido y con respuestas de error. | Cada vez que se modifique Reportes o el cliente HTTP. | El PDF se abre correctamente y JSON/HTML no se descargan como un informe válido. |
| R5-A02 | Revisar la entrega previa y la confirmación del repartidor al reoptimizar. | En cada cambio del flujo de versiones. | La primera entrega conserva su fecha y la nueva versión registra recepción efectiva. |
| R5-A03 | Revisar las versiones de las dependencias antes de preparar una entrega. | Antes de publicar una versión. | Se conserva el informe y se comprueba la corrección de los hallazgos detectados. |

**Responsable de seguimiento:** Jordy. Estas acciones se revisarán en el siguiente trabajo relacionado; su cumplimiento se registrará cuando se realicen.

Los problemas y sus correcciones se detallan en el [registro de impedimentos](02%20Registro%20de%20Impedimentos%20V_1_0_0.md). Los [resultados y evidencias](../evidencias/20261114-desarrollo-integral/RESULTADOS.md) respaldan las comprobaciones mencionadas.

[Índice](README.md)
