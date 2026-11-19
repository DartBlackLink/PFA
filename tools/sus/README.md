# Aplicación y cálculo de SUS

La [encuesta anónima](../../docs/03%20Implementaci%C3%B3n/Sprint%204/instrumentos/Encuesta_SUS.html) se abre en un navegador o se distribuye como archivo HTML. No solicita identificación ni contraseña, no envía datos por red y descarga un CSV por participante. El facilitador verifica que cada persona haya realizado sus tareas y entregue una sola respuesta. El código aleatorio no prueba identidad ni evita por sí solo que una persona responda dos veces.

La adaptación española y su versión deben revisarse antes de iniciar la muestra y mantenerse iguales para todos. No se presenta como traducción validada. Para teclado y pantalla pequeña se usan controles HTML nativos con etiquetas y grupos; la encuesta puede imprimirse. Las pruebas automáticas del formulario son datos sintéticos descartados, no resultados humanos.

## Procedimiento

1. Reunir al menos cinco personas que representen los dos perfiles; anotar cuántas probaron cada rol y el criterio de selección. Explicar voluntariedad y anonimato.
2. Probar tareas QA por rol descritas en el formulario. El facilitador registra en notas separadas éxito, ayuda y errores de cada tarea, sin datos personales.
3. Cada participante contesta diez preguntas y descarga su CSV. Guardar originales por un medio acordado; no recopilar contraseñas ni publicar datos identificables.
4. Unir los archivos desde la raíz, indicando sus rutas reales:

```text
python tools/sus/merge_sus.py RESPUESTA_1.csv RESPUESTA_2.csv --output reports/sus/respuestas-unidas.csv
python tools/sus/score_sus.py reports/sus/respuestas-unidas.csv --output reports/sus
```

El primer comando es un ejemplo de sintaxis, no declara dos participantes recibidos. Debe incluir todos los archivos reales. Rechaza códigos duplicados, respuestas incompletas, campos personales inesperados, valores fuera de 1–5 y ausencia de consentimiento. No sobrescribe los originales. El segundo genera `RESULTADO_SUS.md` y `sus-resultados.json`, con respuestas, contribuciones, media exacta, grado y SHA256 de entrada. Con menos de cinco respuestas no asigna una media global ni un grado.

No convertir el resultado en porcentaje. La comparación docente es ≥68, y la clasificación usa una única escala curva identificada en el [informe de usabilidad](../../docs/03%20Implementaci%C3%B3n/Sprint%204/04%20Usabilidad%20V_1_0_0.md). El grado utiliza redondeo decimal a una cifra, mitad hacia arriba; la media exacta se conserva. Publicar resultados solo tras revisar anonimato y consentimiento.

## Comprobar el calculador

`python -m unittest discover -s tools/sus -p 'test_*.py' -v` comprueba límites, polaridad, duplicados, consentimiento y muestra insuficiente. Los números de estos tests son fixtures algebraicos; no se incorporan al estudio.

[README principal](../../README.md)
