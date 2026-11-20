# Análisis de pruebas E2E y monitoreo con Playwright

**Proyecto:** EcoLogística Huancayo. **Responsable:** Jordy Steve Chancasanampa Torres. **Sprint:** 4. **Versión del contenido:** 1.4.0. **Corte:** 18/11/2026.

## Entorno reproducible y arquitectura

Suite nativa Playwright 1.65.1, Node 22 o superior y Flutter 3.47.7. Se ejecutan Chromium, Firefox y WebKit reales, no tres vistas de un mismo navegador. La web compilada se conecta a FastAPI 8010 y se sirve en 8095; PostgreSQL utiliza esquemas QA nuevos con migraciones reales. No se usa la base operativa ni una contraseña ADMIN existente.

La [configuración](../../../playwright.config.ts) fija navegador, zona America/Lima, viewport, tiempos y reportes. [Inicializador QA](../../../tools/e2e/serve.py), [fixtures y monitoreo](../../../tests/e2e/fixtures.ts), [casos web](../../../tests/e2e/web.spec.ts), [GOLD](../../../tests/e2e/gold.spec.ts) y [validación del formulario SUS](../../../tests/e2e/sus.spec.ts) separan responsabilidades. Los [pasos de ejecución](../../../tools/e2e/README.md) incluyen instalación y compilación; los passwords QA se generan en memoria y se retiran al terminar. No se guardan HAR, storageState ni trazas crudas con credenciales.

## Casos críticos automatizados

| Caso | Escenario y comprobación |
|---|---|
| GOLD-S4 | Generar y confirmar por UI, mapa de Huancayo, rechazo 404 de ruta ajena, iniciar y entregar, reportar incidencia/replanificar/aprobar por API, confirmar recepción y última entrega por UI; comprobar versión 2 recibida e instante de entrega anterior intacto. |
| AUTH-01 / infeliz | Campos vacíos: mensajes de validación y ninguna petición de login. |
| AUTH-02 / feliz | ADMIN consulta panel e indicadores y conserva sesión tras recargar. |
| AUTH-03 / infeliz | Una credencial inválida independiente por navegador devuelve 401 y conserva login; no se confunde el bloqueo 429 al tercer fallo con un defecto. |
| ROLE-01 | REPARTIDOR consulta su operación y no entra al panel ADMIN. |
| PERM-01 | Servidor devuelve 401 a anónimo y 403 al repartidor en vehículos. |
| FORM-01 / borde | Pedido sin obligatorios mantiene modal, marca campo inválido y no realiza escritura. |
| UX-01 / borde | Login a 360 px, campos dentro del ancho y cambio de modo claro/oscuro. No equivale a certificación WCAG. |
| NET-01 | Desconectar y reconectar el contexto muestra error recuperable, conserva sesión y vuelve a consultar. |
| SUS-UI | Formulario anónimo valida obligatorios y consentimiento, cabe a 360 px y descarga CSV sin enviar respuestas por red; son selecciones de prueba descartadas. |

El GOLD es una prueba híbrida UI/API: los pasos de incidencia, replan y aprobación usan la API autenticada. No se presentan como clicks de esos tres formularios. Las comprobaciones históricas por botones del 17/11 siguen identificadas como otro corte.

## Resultados reales

**30 ejecuciones aprobadas de 30, cero fallidas, omitidas o flaky; tasa observada 100 % en esta suite.** Son diez casos por tres motores, no cobertura del 100 % de todas las posibilidades del producto. Duración total registrada: 279,719 s. Véanse [matriz por caso/navegador](../evidencias/20261118-semana14/MATRIZ_E2E.md), [HTML Playwright](../evidencias/20261118-semana14/playwright-html/index.html), [JSON](../evidencias/20261118-semana14/playwright-results.json) y [JUnit](../evidencias/20261118-semana14/playwright-junit.xml).

La regresión posterior a las correcciones aprobó **145 pruebas backend**, sin cambiar el umbral 81 %. Cobertura combinada backend: **2882/3200 ≈ 90.0625 %**, líneas 2329/2500 y ramas 553/700; [XML](../evidencias/20261118-semana14/coverage.xml) y [HTML coverage.py](../evidencias/20261118-semana14/htmlcov/index.html). Flutter conserva el corte del 17/11 con 103 aprobadas; no se volvió a ejecutar porque no cambió el código Dart. La herramienta de cálculo SUS tiene diez pruebas unitarias adicionales; no son encuestas ni tests del backend.

## Rendimiento web y API

Se ejecutaron nueve navegaciones adicionales sin interacción: tres contextos nuevos por motor en el login principal local. Se espera FCP y se observa durante otros 3000 ms. TTFB = responseStart − requestStart, FCP = first-contentful-paint y LCP = última entrada elegible de esa ventana. La tabla muestra medianas; n cambia según las entradas expuestas. Se conserva la primera carga fría y los máximos en el JSON; no se rellenan ausencias con cero o tiempos del algoritmo. [Resultados, versiones y equipo](../evidencias/20261118-semana14/web-vitals-navegacion.json); [medidor reproducible](../../../tools/quality/measure_vitals.mjs).

| Motor | TTFB observado | FCP observado | LCP observado |
|---|---|---|---|
| chromium | 3,200 ms; n=3 | 1332,000 ms; n=3 | Sin entrada reportada; no sustituida. |
| firefox | 8,000 ms; n=3 | 1575,000 ms; n=3 | Sin entrada reportada; no sustituida. |
| webkit | 2,000 ms; n=3 | 1237,000 ms; n=3 | 1282,000 ms; n=3 |

Flutter pinta mediante canvas. Un motor puede no exponer LCP, o no encontrar un elemento elegible; cada adjunto registra soporte y limitación. Por eso estas ausencias no se presentan como cumplimiento de un umbral LCP. Las medidas son locales, con caché y características del equipo de prueba; no certifican producción.

Se repitió además el GOLD en los tres navegadores, esperando respuestas HTTP 200 de teselas OSM antes de capturar. Las tres repeticiones aprobaron y conservaron la entrega inicial. Son tres revalidaciones, no tres casos funcionales nuevos: [reporte visual](../evidencias/20261118-semana14/playwright-visual-html/index.html) y [JSON](../evidencias/20261118-semana14/playwright-visual-results.json).

La traza de red guarda método, ruta, estado y tiempo hasta observar la respuesta, sin cuerpos, cabeceras ni tokens. Captura las peticiones de la página observada, no todos los comandos API de preparación del fixture. No se atribuye a todas las APIs una respuesta menor de 500 ms: la optimización es una operación de cálculo con objetivo propio. Los tiempos de servidor y sus 15 escenarios están separados en [rendimiento](../evidencias/20261118-semana14/RENDIMIENTO.md).

## Disponibilidad, resiliencia y errores corregidos

El [monitor local](../evidencias/20261118-semana14/disponibilidad-local.json) obtuvo 12/12 comprobaciones de salud entre 2026-11-19T02:22:30.381430+00:00 y 2026-11-19T02:22:40.525278+00:00. Es disponibilidad de esos endpoints en esa ventana, no uptime mensual ni prueba suficiente de una entrega. NET-01 comprueba desconexión y recuperación desde el navegador.

Se corrigieron dos causas de aplicación: consultas viales redundantes y la petición OSRM con una sola coordenada. La evidencia conserva los fallos originales, el diagnóstico, cuatro regresiones nuevas y la validación posterior. También se corrigió la instrumentación: puertos compartidos con el stub, selectores semánticos, desplazamiento a controles fuera de pantalla, edición de texto WebKit y datos de login compartidos que activaban correctamente el 429.

No se declaran ejecutados los workflows en GitHub ni un despliegue público. Véanse [CI/CD](12%20Automatizaci%C3%B3n%20CI-CD%20V_1_0_0.md) y [control de Semana 14](CONTROL_SEMANA14.md).


[← Volver al README principal](../../../README.md)


## Actualización de publicación — 19/11/2026

La [web pública de EcoLogística Huancayo](https://ecologistica-huancayo-web.wasmer.app/) y FastAPI en Wasmer están conectados con Neon. Se comprobaron 41 operaciones/contratos API y 12 comprobaciones de Chromium; el repartidor confirmó por UI la recepción v2 y la última entrega. La persistencia se contrastó directamente en PostgreSQL. [Evidencias y límites](../evidencias/20261119-despliegue-publico/RESULTADOS.md).

Este corte sustituye la ausencia de URL/proveedor indicada al 18/11; los resultados históricos conservan su fecha. No se publicaron cambios en GitHub ni se ejecutó Actions. El workflow preparado para VPS requiere adaptarse a Wasmer y comprobarse; la carga actual fue manual. SUS sigue sin respuestas reales y la aceptación formal continúa por realizar. No se declaran aprobados esos requisitos por disponer de URL.

## Evidencia pública explicada — 19/11/2026

El [expediente visual de Semana 14](EVIDENCIAS_PUBLICAS_SEMANA14.md) enlaza las capturas de ADMIN, mapa de Huancayo y entregas del REPARTIDOR con las respuestas HTTP y persistencia de la misma prueba. Explica el estado previo al acuse y el estado final recibido; no atribuye a una captura de navegación una prueba completa de CRUD. Se reutilizan evidencias originales del 19/11, sin repetir operaciones ni incluir credenciales. SUS y Actions mantienen su estado pendiente de resultados propios.

## Ejecución remota y corrección — 20/11/2026

Tras publicar el commit 83d5652, GitHub Actions ejecutó CI con éxito y aprobó los jobs backend y Flutter. La suite E2E remota registró 28/30 aprobadas: GOLD-S4 y UX-01 fallaron en WebKit al esperar el activador transitorio de accesibilidad. Se corrigió la sincronización del auxiliar y su copia tras recarga. Quince regresiones aisladas aprobaron en los tres motores; se mantiene intacta la suite de negocio para volver a comprobarla en GitHub. El [expediente de corrección](../evidencias/20261120-correccion-actions/RESULTADOS.md) distingue fallo original, causa, prueba anterior/corregida y verificación remota pendiente al corte. Los resultados locales del 18/11 se conservan con su entorno, sin sustituir el resultado remoto fallido.
