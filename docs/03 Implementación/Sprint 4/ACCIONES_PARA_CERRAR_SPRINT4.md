# Acciones para ejecutar y cerrar el Sprint 4

**Proyecto:** EcoLogística Huancayo. **Responsable:** Jordy Steve Chancasanampa Torres. **Fecha:** 13/11/2026. Este archivo reúne trabajo posterior al expediente documental; no son resultados ejecutados ni un registro de impedimentos.

## 1. Jira: cómo dejar el alcance coherente

En el [backlog EHAPP, tablero 35](https://ecologistica.atlassian.net/jira/software/c/projects/EHAPP/boards/35/backlog):

1. Acordar con el docente las fechas reales y revisar el estado administrativo de los sprints anteriores sin inventar cierres ni retrofechar reuniones.
2. Crear **EHAPP Sprint 4 — Mapa, dashboard y rendimiento**, con esas fechas y el objetivo del Informe. Conservar el ID que Jira asigne; este documento no le adjudica uno.
3. Asociar **EHAPP-15/US-006 (5 SP)**, **EHAPP-16/US-007 (5 SP)** y **EHAPP-14/EN-002 (5 SP)**. Total propuesto aceptado para preparar documentos: **15 SP**. Confirmar que no se arrastró EHAPP-13/S3 ni el total LEG-V1.2 de 21 SP.
4. Añadir a la descripción de cada candidata los criterios S4-MAP, S4-DASH y S4-PERF correspondientes de la Revisión; no reemplazar criterios válidos sin conservar el motivo del cambio.
5. Dividir en subtareas ejecutables si se necesita: datos/contrato, interfaz, pruebas y evidencia. No sumar sus estimaciones de nuevo a los SP del padre.
6. Vincular estos documentos y posteriormente la versión y pruebas. Mover a Done solo después de comprobar criterios y DoD, no por terminar la redacción.

No se ejecutaron estos cambios de Jira. La [consulta inicial](evidencias/consulta-jira-20261113.json) conserva el estado anterior.

## 2. Aplicación y evidencia: qué comprobar

| Acción | Cómo realizarla | Evidencia necesaria |
|---|---|---|
| Fijar versión candidata | Comparar las fuentes de D con la copia PFA, identificar qué versión se va a evaluar y conservar manifest/commit. No sobrescribir cambios recientes. | Hashes o commit, build servido y entorno. Este encargo no sincroniza código. |
| Mapa completo | Recorrer ADMIN y REPARTIDOR; contrastar origen, trazado vial, paradas, orden, estado y propietario. Provocar ubicación insuficiente sin inventarle coordenadas. | Capturas de Huancayo y respuestas/lecturas del mismo ID/versión, saneadas. |
| Dashboard | Comprobar los cuatro indicadores definidos, cambio de plan, ausencia de factores, rutas canceladas y cero entregas evaluables. | Dataset de entrada y cálculo independiente con unidades, más capturas y resultado por criterio. Los conteos del resumen no bastan. |
| Rendimiento | Preparar dataset aislado y ejecutar el protocolo del anexo 09 con cinco semillas y tamaños 10/50/150. | Tiempos crudos, máximos/medianas, régimen de caché y verificación de factibilidad. |
| Calidad | Ejecutar suites pertinentes de la versión candidata, cobertura y análisis; Sonar solo con credencial nueva privada. | JUnit/XML/HTML, comandos, fecha, versión, analysisId y gate. No reutilizar porcentajes anteriores como nuevos. |
| Seguridad | Ejecutar los casos del anexo OWASP y revisar que los rechazos no cambien datos. | Evidencia de autorización, entrada inválida, transacciones y gestión de errores; ningún token. |
| Accesibilidad | Teclado, lector, contraste, reflujo y estados en ambos temas. | Matriz criterio/resultado/hallazgo/corrección; capturas complementarias. |

## 3. Capturas: qué mostrar y cómo guardarlo

Después de ejecutar cada caso, guardar archivos con nombres descriptivos y fecha dentro de `Sprint 4/evidencias/`, por ejemplo mapa-admin-huancayo, mapa-repartidor-propio, dashboard-plan-seleccionado, dashboard-dato-insuficiente, benchmark-150-15 y revisión-jira-s4. **Estos nombres son una convención propuesta; no representan archivos que ya existan.**

Antes de capturar: ocultar claves, tokens y datos personales; mostrar el contexto necesario, unidades, estado y versión. Las coordenadas deben ser de puntos públicos autorizados de Huancayo. Una captura del mapa no reemplaza la medición; el benchmark necesita resultados crudos. No reutilizar imágenes de Lima ni imágenes del ejemplo como evidencia propia.

## 4. Review, retrospectiva y publicación

Registrar fecha, asistentes reales, criterios demostrados, feedback y decisión por historia. En la retrospectiva completar problemas efectivamente encontrados durante la ejecución, corrección comprobada, aprendizaje y compromisos con responsable y hito. Mantener la reflexión preparatoria del 13/11 como corte identificado.

Revisar enlaces, correspondencia de nombres/versiones y secretos antes de incorporar archivos al control de versiones. Este encargo **no autoriza commit/push** ni modificar la aplicación. PDF/EHAPP-19 y APK release no se incorporan automáticamente al Sprint 4; si el docente los exige, acordar un cambio de alcance antes de declararlos comprometidos.

[Índice del Sprint 4](README.md) · [Revisión y criterios](03%20Revisi%C3%B3n%20del%20Sprint%20V_1_0_0.md)
