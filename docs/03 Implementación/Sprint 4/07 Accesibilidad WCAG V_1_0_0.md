# Accesibilidad WCAG — Sprint 4

**Proyecto:** EcoLogística Huancayo. **Responsable:** Jordy Steve Chancasanampa Torres. **Versión:** 1.0.0. **Fecha:** 13/11/2026.

## Objetivo y alcance

Objetivo del RNF-03: [WCAG 2.1 nivel AA](https://www.w3.org/TR/WCAG21/) en las vistas y flujos aplicables. Se revisarán mapa/lista, indicadores, filtros y mensajes desde Web ADMIN y REPARTIDOR. Es un plan de evaluación: no se declara conformidad integral a partir de una captura o de las pruebas Flutter anteriores.

## Matriz preparada

| Principio / criterio | Comprobación propia prevista | Evidencia requerida |
|---|---|---|
| Perceptible: 1.1.1, 1.3.1 y 1.4.1 | Lista textual equivalente al mapa; estados e indicadores identificados sin depender del color. | Lectura de orden/estado y comparación con el mapa. |
| Perceptible: 1.4.3 y 1.4.11 | Contraste de texto y controles en ambos temas; objetivos 4,5:1 texto normal y 3:1 texto grande. | Medición de colores y componente evaluado. |
| Perceptible: 1.4.4, 1.4.10 y 1.4.12 | Texto ampliado, reflujo y espaciado sin perder acciones esenciales. | Prueba a 320 CSS px cuando aplique y revisión en 360/768/1440. |
| Operable: 2.1.1, 2.1.2 y 2.4.7 | Teclado en filtros, selección y modales; foco visible y recuperado al cerrar. | Recorrido manual de teclado y resultado. |
| Operable: 2.2.1 | Avisos y límites de sesión según el criterio aplicable. | Evaluación del tiempo y mecanismo existente. |
| Comprensible: 3.3.1 y 3.3.2 | Errores identifican el campo y cómo corregirlo. | Captura y lectura del mensaje. |
| Robusto: 4.1.2 y 4.1.3 | Nombres/roles/valores y anuncios de cambios en indicadores. | Lectura con Narrador u otro lector identificado. |

## Procedimiento de evaluación

1. Registrar versión, navegador, tamaño, tema y tecnología de asistencia.
2. Recorrer consulta de ruta y selección del plan con teclado; contrastar la lista con el mapa y leer las métricas con su unidad.
3. Repetir en claro/oscuro, ampliar texto y provocar estados vacío/error/carga. Diferenciar un trazado externo de mapa de los controles propios.
4. Registrar por criterio: aprobado, no conforme o no aplicable con justificación. Un sondeo automático complementa la revisión manual, no la sustituye.

## Hallazgos y estado de este corte

Los [resultados anteriores](../evidencias/20261104-cierre/MATRIZ_ACEPTACION.md) documentan adaptación y pruebas de componentes, pero conservan evaluación manual pendiente. No se realizó una campaña WCAG S4 hoy. Las evidencias futuras deben mostrar el resultado y su versión, sin copiar las del ejemplo ni declarar una prueba de lector inexistente.

Acción de cierre: completar esta matriz con mediciones y recorrido manual real, corregir los fallos y repetir la tarea. La accesibilidad es transversal; no se incorpora EHAPP-18 al compromiso de S4 sin un cambio acordado.

[Índice del Sprint 4](README.md) · [Acciones de cierre](ACCIONES_PARA_CERRAR_SPRINT4.md)
