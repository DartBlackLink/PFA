# Evaluación cuantitativa de usabilidad

**Proyecto:** EcoLogística Huancayo. **Responsable:** Jordy Steve Chancasanampa Torres. **Sprint:** 4. **Versión del contenido:** 1.4.0. **Corte documental:** 19/11/2026.

## Ficha técnica y estado del estudio

Instrumento seleccionado: System Usability Scale (SUS), diez ítems alternados positivos/negativos, Likert 1–5. Se aplicará después de usar la web, con instrucciones idénticas y respuestas individuales sin sugerir una puntuación. Perfiles: personas que representen administración logística y reparto; registrar experiencia digital, rol y dispositivo sin nombres ni documentos de identidad. La rúbrica solicita al menos cinco participantes reales; ese mínimo no asegura representatividad estadística.

**Muestra analizable en las fuentes revisadas: 0 participantes.** No se proporcionaron respuestas individuales ni consentimiento/registro anónimo. Por ello no hay media, grado ni adjetivo de usabilidad calculables. Las 103 pruebas Flutter y el porcentaje de cobertura Python no son respuestas de personas.

## Instrumento y cálculo implementados

La [encuesta HTML anónima](instrumentos/Encuesta_SUS.html) está lista para utilizar o imprimir. Sus diez preguntas, escala y consentimiento son obligatorios; genera un CSV sin pedir nombre, correo o contraseña y sin enviar datos por red. La [plantilla CSV](instrumentos/SUS_respuestas.csv) contiene solo cabeceras, no participantes ficticios.

El [procedimiento de aplicación y unión de respuestas](../../../tools/sus/README.md), el [calculador](../../../tools/sus/score_sus.py) y el [unificador](../../../tools/sus/merge_sus.py) generan resultados auditables cuando se reciben respuestas reales. Rechazan datos incompletos, códigos duplicados, falta de consentimiento y valores fuera de 1–5; no sobrescriben originales ni imputan respuestas. Diez pruebas algebraicas verifican el cálculo, y SUS-UI valida el formulario en tres navegadores. Ninguna de esas pruebas aumenta la muestra humana: sigue en cero según la confirmación del responsable.

## Entorno disponible para aplicar el estudio

La [web pública](https://ecologistica-huancayo-web.wasmer.app/) ya permite realizar las tareas con datos de demostración. El facilitador entrega accesos privados por rol, sin incluir claves en formularios o respuestas. Antes de la encuesta, verifica que cada participante complete o intente sus tareas. La muestra sigue en cero hasta recibir sus CSV reales; la publicación no genera respuestas SUS.

## Tareas previas a responder

| Perfil | Tareas con datos QA autorizados | Datos que deben registrarse |
|---|---|---|
| ADMIN | Iniciar sesión; registrar/editar pedido válido; corregir un dato inválido; generar propuesta, consultar mapa e indicadores y confirmar asignación. | Finalización sin ayuda/con ayuda/no finalizada, duración, errores y observaciones. |
| REPARTIDOR | Consultar ruta propia, confirmar recepción, iniciar, registrar entrega y reportar congestión; recibir y confirmar una actualización autorizada. | Comprensión de estados, recuperación de errores y tareas terminadas. |

No se inducirán incidencias reales ni se alterarán entregas operativas para la encuesta. La evaluación debe indicar qué rol utilizó cada persona; si se calculan subgrupos, declarar su tamaño y evitar generalizar cinco respuestas a toda la población.

## Instrumento y puntuaciones brutas

Se propone la siguiente adaptación española de trabajo, conservando orden y polaridad. No se presenta como traducción validada. Antes de aplicar se revisará comprensión con el instrumento de referencia; se congelará una única redacción para toda la muestra y se conservará esa versión junto con las respuestas. Escala: 1 totalmente en desacuerdo, 2 en desacuerdo, 3 ni de acuerdo ni en desacuerdo, 4 de acuerdo y 5 totalmente de acuerdo.

| Ítem | Afirmación para el participante | Polaridad |
|---|---|---|
| P1 | Usaría EcoLogística con frecuencia. | Positiva. |
| P2 | Encuentro complejidad innecesaria en el sistema. | Negativa. |
| P3 | El sistema me resulta fácil de usar. | Positiva. |
| P4 | Necesitaría ayuda técnica para utilizarlo. | Negativa. |
| P5 | Sus funciones me parecen bien integradas. | Positiva. |
| P6 | Percibo demasiadas inconsistencias en su funcionamiento. | Negativa. |
| P7 | Creo que la mayoría aprendería a usarlo rápidamente. | Positiva. |
| P8 | Me resulta difícil manejar el sistema. | Negativa. |
| P9 | Me siento seguro al utilizarlo. | Positiva. |
| P10 | Debí aprender muchas cosas antes de poder usarlo. | Negativa. |

La confianza de P9 se refiere a la experiencia percibida, no certifica seguridad informática. No se modificarán ítems o eliminarán respuestas para elevar artificialmente el resultado.

| Registro verificado | P1–P10 brutas | SUS individual |
|---|---|---|
| Sin formularios recibidos en el expediente revisado | No existen datos para transcribir. | No calculable. |

No se crean filas de participantes ficticios ni valores neutros para completar la tabla. Al recibir datos, cada fila contendrá código anónimo, rol, diez enteros de 1 a 5 y puntuación derivada; respuestas incompletas se separarán, informando la exclusión, sin imputarlas silenciosamente.

## Cálculo reproducible

Para cada participante con diez respuestas válidas:

1. En P1, P3, P5, P7 y P9, restar 1 a la respuesta.
2. En P2, P4, P6, P8 y P10, restar la respuesta de 5.
3. Sumar las diez contribuciones (entre 0 y 40) y multiplicar por 2,5: SUS individual entre 0 y 100.
4. Sumar las puntuaciones individuales y dividir por el número de participantes válidos. Con n = 0, no se realiza la división.

Se conservarán tanto las respuestas brutas como las contribuciones y sumas para auditar el cálculo. No se ofrece un ejemplo numérico como resultado del proyecto. [Referencia del procedimiento SUS](https://pmc.ncbi.nlm.nih.gov/articles/PMC9437782/).

## Interpretación y mejoras

La consigna fija ≥68 como umbral. SUS es una puntuación normalizada, no un porcentaje de funcionalidad ni de cobertura. La referencia de 68 describe una media de comparación, no garantiza por sí sola una buena experiencia en cada tarea. [Referencia de comparación](https://measuringu.com/ux-benchmarks/).

Para grados se adopta la escala curva de [MeasuringU](https://measuringu.com/sus-items/), aplicada a una cifra decimal, conservando el valor exacto en la tabla de cálculo:

| Grado | Intervalo SUS |
|---|---|
| A+ | 84,1–100 |
| A | 80,8–84,0 |
| A− | 78,9–80,7 |
| B+ | 77,2–78,8 |
| B | 74,1–77,1 |
| B− | 72,6–74,0 |
| C+ | 71,1–72,5 |
| C | 65,0–71,0 |
| C− | 62,7–64,9 |
| D | 51,7–62,6 |
| F | 0–51,6 |

Se utilizarán los grados, sin inventar equivalencias adjetivales de otra escala. Actualmente grado e interpretación del proyecto son no calculables porque no hay respuestas. Una clasificación futura deberá distinguir el umbral docente de 68 del rango de cada grado.

| Hallazgo técnico previo | Mejora comprobada | Lo que todavía requiere observación humana |
|---|---|---|
| El modal de tráfico cerraba ante factor 0 y exponía un error técnico. | Validación local en español y conservación de campos, 17/11. | Si el usuario entiende cómo corregirlo sin ayuda. |
| Poco contraste del recorrido inicial sobre OSM en modo oscuro. | Azul con borde blanco y regresiones para ambos temas, 17/11. | Legibilidad en dispositivos y tareas de los participantes. |
| ETA e indicadores incompletos en asignaciones manuales. | Persistencia y visualización corregidas, 14/11. | Comprensión de estimaciones frente a resultados reales. |

Las capturas y pruebas están en los [resultados del 17/11](../evidencias/20261117-verificacion-final/RESULTADOS.md). Son hallazgos técnicos, no hallazgos de una encuesta ya aplicada. El siguiente paso es aplicar el instrumento, revisar errores por tarea y priorizar mejoras según frecuencia e impacto. Responsable: Jordy; evidencia exigida en las [acciones de cierre](ACCIONES_PARA_CERRAR_SPRINT4.md).


[← Volver al README principal](../../../README.md)


## Actualización de publicación — 19/11/2026

La [web pública de EcoLogística Huancayo](https://ecologistica-huancayo-web.wasmer.app/) y FastAPI en Wasmer están conectados con Neon. Se comprobaron 41 operaciones/contratos API y 12 comprobaciones de Chromium; el repartidor confirmó por UI la recepción v2 y la última entrega. La persistencia se contrastó directamente en PostgreSQL. [Evidencias y límites](../evidencias/20261119-despliegue-publico/RESULTADOS.md).

Este corte sustituye la ausencia de URL/proveedor indicada al 18/11; los resultados históricos conservan su fecha. No se publicaron cambios en GitHub ni se ejecutó Actions. El workflow preparado para VPS requiere adaptarse a Wasmer y comprobarse; la carga actual fue manual. SUS sigue sin respuestas reales y la aceptación formal continúa por realizar. No se declaran aprobados esos requisitos por disponer de URL.

## Aplicación de la encuesta acordada — 19/11/2026

El responsable confirmó que reunirá cinco respuestas reales. La [guía de aplicación](instrumentos/GUIA_APLICACION_SUS.md) concreta selección de participantes, sesiones por rol, tareas QA, consentimiento, descarga y entrega de CSV, observaciones y cálculo. La [hoja de observación](instrumentos/SUS_observaciones.csv) contiene solo cabeceras; no representa participantes ni tareas ejecutadas.

La encuesta se abre desde el HTML local; no se ha publicado una URL propia del formulario. No se modificaron sus diez ítems. No se requieren ni publican tokens para aplicar SUS. La actualización autorizada es documental: respuestas reales recibidas siguen en cero; aún no existen media ni grado del proyecto.
