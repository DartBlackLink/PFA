# Guía para aplicar SUS a cinco personas reales

**Proyecto:** EcoLogística Huancayo. **Responsable y facilitador:** Jordy Steve Chancasanampa Torres. **Corte:** 19/11/2026. **Instrumento:** adaptación española de trabajo SUS 1.0.0 del 18/11; se conserva su redacción.

## Propósito y preparación

Esta evaluación responde si las personas comprenden y pueden usar la web. No mide cobertura de código ni reemplaza las pruebas funcionales. El responsable confirmó que reunirá cinco respuestas; todavía no se han recibido CSV de personas reales. No se genera un puntaje hasta disponer de ellos.

Reunir al menos cinco personas distintas que representen los dos roles. Una distribución propuesta es tres ADMIN y dos REPARTIDOR; se registrará la composición que realmente participe, sin presentarla como una muestra estadísticamente representativa. Cada persona entrega una sola encuesta tras probar su rol. No se repite la encuesta buscando elevar el promedio.

1. Abrir la [web pública](https://ecologistica-huancayo-web.wasmer.app/) y comprobar disponibilidad antes de cada sesión. Anotar fecha, dispositivo, rol y versión probada. Si la versión cambia durante el estudio, dejar constancia y analizar su comparabilidad.
2. Abrir la [encuesta HTML](Encuesta_SUS.html) en un navegador desde la copia local de PFA. **No tiene todavía una URL pública propia** y no está integrada al menú de la aplicación. Puede entregarse el mismo archivo HTML a cada participante; no requiere instalación ni acceso a PostgreSQL.
3. Utilizar sesiones supervisadas o accesos QA autorizados, entregados por vía privada. No distribuir la contraseña del administrador como parte del formulario, una captura o un documento público.
4. Preparar pedidos/rutas de demostración identificables antes de las tareas. La ruta utilizada en las pruebas del 19/11 ya terminó: no se vuelve a iniciar ni se altera su historial para la encuesta. Preparar un caso nuevo autorizado para tareas de entrega e incidencia.
5. Explicar voluntariedad, anonimato y retiro. El formulario solicita consentimiento y descarga un CSV; no envía las respuestas a un servidor. Acordar previamente cómo entregarán los CSV al facilitador.

## Explicación que da el facilitador

«Vamos a evaluar EcoLogística, no tus conocimientos. Intenta las tareas del rol que vas a probar. Puedes expresar dudas o dejar de participar. Si necesitas ayuda, la registraré para mejorar el sistema. Al terminar, responde las diez afirmaciones según tu experiencia; no hay respuestas correctas y no necesitas conseguir un puntaje determinado. No escribas datos personales ni contraseñas».

No sugerir que marque 4 o 5, no explicar la polaridad para influir y no mostrarle las respuestas de otras personas. Si una tarea falla, registrar el fallo y permitir que valore la experiencia; no excluirlo por obtener una puntuación baja.

## Tareas de prueba

| Código | Perfil | Tarea concreta | Evidencia de observación |
|---|---|---|---|
| A1 | ADMIN | Ingresar y encontrar Pedidos. | Encuentra el apartado sin ayuda, con ayuda o no logra hacerlo. |
| A2 | ADMIN | Registrar o editar un pedido QA con destino válido de Huancayo y ventana horaria coherente. | Comprende campos, conserva datos y reconoce la confirmación. |
| A3 | ADMIN | Intentar guardar un dato inválido y corregirlo. | Entiende el mensaje y completa la corrección sin perder información. |
| A4 | ADMIN | Generar propuesta, leer recorrido/indicadores y confirmar una asignación QA. | Distingue propuesta de asignación guardada; identifica al repartidor. |
| R1 | REPARTIDOR | Ingresar y encontrar únicamente la ruta propia del caso QA. | Localiza pedidos, orden, destino y estado. |
| R2 | REPARTIDOR | Confirmar recepción, iniciar y registrar una entrega QA. | Comprende botones y verifica que el estado persiste. |
| R3 | REPARTIDOR | Reportar congestión simulada para un pedido pendiente. | Comprende ubicación, detalle y envío del reporte. |
| R4 | REPARTIDOR | Recibir la nueva planificación aprobada por ADMIN y confirmar su recepción. | Reconoce actualización e historial y conserva la entrega ya realizada. |

Para R3/R4 el facilitador coordina la sesión ADMIN que recibe la incidencia y aprueba la reoptimización. Si ese contexto no está listo, registrar la tarea no realizada y su motivo; no describirla como observada. Las incidencias son simuladas y no constituyen información de tráfico en tiempo real.

## Registro de observaciones y respuestas

Usar [SUS_observaciones.csv](SUS_observaciones.csv), que contiene únicamente cabeceras. Después de descargar la respuesta, asociar el mismo código anónimo a las tareas observadas. Registrar una fila por tarea: código, rol, dispositivo, fecha, tarea, resultado, duración en segundos, ayuda y observación sin datos personales. Resultados: SIN_AYUDA, CON_AYUDA, NO_COMPLETADA o NO_REALIZADA. Si no se midió duración, dejarla sin valor y explicar el límite; no estimarla como si fuera cronometraje.

Cada persona selecciona rol/dispositivo, responde P1–P10, marca consentimiento y pulsa «Descargar mis respuestas anónimas». Entrega el archivo `SUS-<código aleatorio>.csv` por el medio acordado. El código aleatorio no demuestra que sea una persona distinta; el facilitador controla una participación por persona sin publicar identidades.

Guardar los originales y observaciones fuera de PFA, en una carpeta privada local autorizada. No incluir nombres, correos, teléfonos, claves ni grabaciones sin consentimiento. La falta de una tarea no autoriza a completar respuestas por el participante.

## Cálculo real y revisión

Desde la raíz de PFA se utilizan los programas existentes. El [README del calculador](../../../../tools/sus/README.md) explica la sintaxis; se pasan las rutas de los archivos realmente recibidos a `merge_sus.py` y luego la salida a `score_sus.py`. Elegir una carpeta de salida nueva por corte, porque el calculador escribe los informes de esa carpeta. Conservar originales inalterados.

El unificador rechaza formatos incorrectos y códigos duplicados. El cálculo verifica consentimiento y diez enteros de 1 a 5: impares respuesta − 1, pares 5 − respuesta; suma × 2,5. El informe conserva respuestas, contribuciones, puntuaciones, media exacta, grado, fecha y SHA256 de entrada. Con menos de cinco válidas no emite una media global ni grado.

Revisar el anonimato antes de incorporar resultados al expediente. Relacionar las dificultades observadas con acciones concretas: problema encontrado, tarea afectada, cambio propuesto, responsable y prueba con que se verificará. Un promedio ≥68 cumple el umbral docente, pero no elimina los fallos observados ni representa un porcentaje de funcionalidad.

## Evidencias para cerrar el requisito

- Cinco o más respuestas válidas de personas distintas, con versión del instrumento, fecha, rol y dispositivo.
- Registro de tareas observadas, ayuda y fallos; composición real de la muestra y limitaciones.
- CSV anónimo consolidado, informe Markdown y JSON calculados, comando real ejecutado y SHA256 de entrada.
- Actualización del [informe de usabilidad](../04%20Usabilidad%20V_1_0_0.md) con resultados y conclusiones sustentadas. Se conserva el corte anterior como antecedente; no se convierte la preparación en un estudio ya aplicado.

**Estado al corte:** instrumento y procedimiento preparados; respuestas recibidas: 0; puntuación y grado: no calculables. La promesa de reunir personas no se registra como participación realizada.

[Informe de usabilidad](../04%20Usabilidad%20V_1_0_0.md) · [Índice Sprint 4](../README.md) · [README principal](../../../../README.md).
