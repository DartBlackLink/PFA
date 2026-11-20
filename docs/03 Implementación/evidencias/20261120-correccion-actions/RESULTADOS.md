# Corrección de sincronización E2E en GitHub Actions — 20/11/2026

**Proyecto:** EcoLogística Huancayo. **Alcance:** instrumentación de pruebas del Sprint 4, sin cambios en la aplicación ni datos de Wasmer/Neon.

## Fallo observado y diagnóstico

El [workflow original](https://github.com/DartBlackLink/PFA/actions/runs/44625847243), commit 83d5652, aprobó backend y Flutter. Playwright aprobó 28 casos y falló GOLD-S4/UX-01 en WebKit. Ambos agotaron 20000 ms esperando `flt-semantics-placeholder` en fixtures.ts:18. El [resumen sanitizado](fallo-github-original.json) preserva los resultados; el log completo permanece fuera del repositorio. CI independiente aprobó; producción fue omitida.

El auxiliar hacía dos consultas separadas: contaba el activador y después esperaba localizarlo para pulsarlo. Flutter puede retirar/reemplazar ese nodo cuando activa accesibilidad: la existencia comprobada no garantiza que siga presente en la siguiente operación. También podía montar el activador después de la comprobación inicial. Había una segunda copia de ese patrón tras recargar el dashboard.

## Corrección

Se centraliza la activación en [flutter-semantics.ts](../../../../tests/e2e/flutter-semantics.ts). La búsqueda y el clic opcional ocurren en una única tarea de navegador; la sincronización termina al observar el control accesible requerido, no al encontrar el activador transitorio. El login espera un textbox y la recarga espera Pedidos. Se conserva el límite de activación de 20 segundos, no se desactivan validaciones, no se añaden reintentos de casos y no se ocultan excepciones generales.

## Regresión ejecutada

La [suite aislada](../../../../tests/browser/flutter-semantics.spec.ts) comprueba pantalla ya activa, activador tardío, desaparición antes de terminar de cargar, activación automática y espera de un control del dashboard. No usa usuarios, backend, base ni mocks de reglas de negocio: comprueba únicamente el protocolo de accesibilidad en DOM controlado.

| Ensayo | Resultado real |
|---|---|
| Auxiliar anterior, activador tardío, WebKit | Una prueba falló como se esperaba: no se activó el textbox. Se conservó el código anterior durante ese ensayo aislado y después se restauró la corrección. |
| Auxiliar corregido, cinco escenarios × tres motores | 15 aprobadas, cero omitidas, cero flaky y cero reintentos; 18,300 s en la ejecución local registrada. |

El primer lanzamiento dentro del aislamiento no encontró los navegadores instalados y no ejecutó las comprobaciones; se repitió fuera del aislamiento con la ruta de los navegadores existentes. No se descargaron nuevos navegadores ni se atribuyó ese problema de entorno a la aplicación.

Comando ejecutado en el árbol aislado: `node node_modules/playwright/cli.js test --config playwright.semantics.config.ts`. En el repositorio, el equivalente es `npm run test:e2e:semantics`. [Resultado resumido, motores, fecha y hash del auxiliar](regresion-local.json).

## Verificación en GitHub

El workflow mantiene la suite original de 30 casos, los tres motores, permisos, aislamiento PostgreSQL y criterios de negocio. Añade antes las 15 regresiones de accesibilidad y conserva JSON/JUnit como artifacts. La regresión aislada local no demuestra por sí sola que el GOLD real haya pasado en Linux: se comprobará el nuevo run correspondiente al commit de esta corrección. No se anticipa su resultado en este corte documental.

SUS humano y adaptación CD Wasmer son requisitos separados, no corregidos por este cambio. La URL manual continúa operativa sin ser reemplazada por esta tarea.

[Sprint 4](../../Sprint%204/README.md) · [README principal](../../../../README.md).
