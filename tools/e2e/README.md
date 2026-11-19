# Pruebas E2E reproducibles de EcoLogística Huancayo

La suite prueba la compilación Flutter y FastAPI reales sobre PostgreSQL QA. No sustituye endpoints por mocks ni usa credenciales del administrador operativo. El inicializador valida nombre de base y host, crea un esquema nuevo con migraciones y cuentas aleatorias, y conserva el esquema como evidencia. No borra ni trunca tablas previas.

## Requisitos y ejecución

Node 22 o superior, Python con las dependencias del backend, Flutter 3.47.7 y una base **exclusiva de QA** llamada `ecologistica_revision_20261007`. El usuario de esa base necesita permiso CREATE de esquema. Nunca proporciones el DSN de la base operativa. Configura mediante el entorno privado `E2E_QA_DATABASE_URL`, `E2E_ALLOW_SCHEMA_CREATE=1` y, si corresponde, `E2E_PYTHON`. Las claves de las cuentas E2E se generan al cargar la configuración; no hay contraseña fija.

Desde la raíz de PFA:

```text
npm ci --ignore-scripts
npx playwright install chromium firefox webkit
```

En `apps/web`, compila:

```text
flutter pub get --enforce-lockfile
flutter build web --release --output build/e2e --dart-define=API_BASE_URL=http://127.0.0.1:8010/api/v1
```

Después, desde la raíz, `npm run test:e2e`. Si se utiliza un árbol de desarrollo diferente, `E2E_APP_ROOT` identifica la raíz con `backend/`; `E2E_WEB_DIR` identifica la compilación de QA. Los puertos reservados por la suite son API 8010 y web 8095. El 8090 queda reservado al proveedor controlado de la regresión backend. No se reutiliza silenciosamente un servidor anterior; debe detenerse o elegirse un ensayo separado.

## Resultados y privacidad

`reports/playwright-html/index.html` es el reporte visual; `npm run test:e2e:report` lo abre solo en localhost. JSON y JUnit describen el resultado por caso y navegador. Los adjuntos incluyen métricas, capturas QA y trazas de red sin cabeceras, cuerpos, parámetros de consulta o credenciales. No se conservan HAR, storageState, videos ni trazas crudas con tokens.

La navegación canvas de Flutter expone sus controles mediante accesibilidad. La suite activa el árbol semántico y escribe con eventos de teclado; no modifica campos mediante JavaScript ni desactiva validaciones. Los textos agrupados y anuncios duplicados se identifican conforme al DOM real.

TTFB y FCP se registran desde Performance API. LCP se guarda solo si el motor expone una entrada elegible; una ausencia en canvas no se reemplaza por otro tiempo. Los tiempos API observados y los errores deliberados de red se etiquetan por caso. Las mediciones locales no acreditan disponibilidad mensual ni rendimiento de producción.

El GOLD combina acciones UI con preparación y comprobación API: generación/confirmación/mapa y operación del repartidor por interfaz; incidencia, replanificación y aprobación por API autenticada. Los informes deben conservar esta distinción. Las selecciones sintéticas usadas para probar el formulario SUS no son participantes ni respuestas del estudio.

## Referencias técnicas

- [Playwright: configuración](https://playwright.dev/docs/test-configuration).
- [Flutter: accesibilidad web](https://docs.flutter.dev/ui/accessibility/web-accessibility).

[README principal](../../README.md)

## Revalidación visual y métricas sin interacción

Para repetir únicamente los tres GOLD esperando teselas OSM: definir `E2E_REPORT_SET=visual` antes de `npm run test:e2e`. Produce archivos `reports/playwright-visual-*`, separados de la ejecución principal. No modifica el número de casos de la suite principal.

Para medir el login en tres contextos nuevos de cada navegador, sin escribir ni hacer clic: `node tools/quality/measure_vitals.mjs --url http://127.0.0.1:8080/#/login --samples 3 --output reports/web-vitals.json`. Primero levantar la web local. Registra equipo, versiones, muestras y disponibilidad de LCP; una ausencia no se sustituye por FCP. No son métricas de usuarios de producción.
