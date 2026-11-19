# Matriz de ejecución E2E — 18/11/2026

Cada fila es una ejecución real; diez casos por tres navegadores. Los datos son QA, sin usuarios operativos. Preparación y pasos API se distinguen en el código y el informe.

| Caso | Navegador | Resultado | Duración (s) |
|---|---|---|---|
| GOLD-S4 · generar, confirmar, mapa Huancayo y entregas propias persistidas | chromium | APROBADO | 33,831 |
| GOLD-S4 · generar, confirmar, mapa Huancayo y entregas propias persistidas | firefox | APROBADO | 29,238 |
| GOLD-S4 · generar, confirmar, mapa Huancayo y entregas propias persistidas | webkit | APROBADO | 46,358 |
| SUS-UI · formulario anónimo valida, se adapta y descarga CSV sin enviarlo | chromium | APROBADO | 1,315 |
| SUS-UI · formulario anónimo valida, se adapta y descarga CSV sin enviarlo | firefox | APROBADO | 1,627 |
| SUS-UI · formulario anónimo valida, se adapta y descarga CSV sin enviarlo | webkit | APROBADO | 1,381 |
| AUTH-01 · infeliz: formulario vacío rechaza sin enviar credenciales | chromium | APROBADO | 2,257 |
| AUTH-01 · infeliz: formulario vacío rechaza sin enviar credenciales | firefox | APROBADO | 2,639 |
| AUTH-01 · infeliz: formulario vacío rechaza sin enviar credenciales | webkit | APROBADO | 3,394 |
| AUTH-02 · feliz: ADMIN, indicadores y sesión después de recargar | chromium | APROBADO | 7,755 |
| AUTH-02 · feliz: ADMIN, indicadores y sesión después de recargar | firefox | APROBADO | 7,815 |
| AUTH-02 · feliz: ADMIN, indicadores y sesión después de recargar | webkit | APROBADO | 13,946 |
| AUTH-03 · infeliz: credencial aleatoria incorrecta mantiene login | chromium | APROBADO | 5,959 |
| AUTH-03 · infeliz: credencial aleatoria incorrecta mantiene login | firefox | APROBADO | 6,088 |
| AUTH-03 · infeliz: credencial aleatoria incorrecta mantiene login | webkit | APROBADO | 10,646 |
| ROLE-01 · REPARTIDOR ve su operación y no entra a ADMIN | chromium | APROBADO | 6,495 |
| ROLE-01 · REPARTIDOR ve su operación y no entra a ADMIN | firefox | APROBADO | 6,511 |
| ROLE-01 · REPARTIDOR ve su operación y no entra a ADMIN | webkit | APROBADO | 11,472 |
| PERM-01 · servidor rechaza anónimo y REPARTIDOR en vehículos | chromium | APROBADO | 0,384 |
| PERM-01 · servidor rechaza anónimo y REPARTIDOR en vehículos | firefox | APROBADO | 0,708 |
| PERM-01 · servidor rechaza anónimo y REPARTIDOR en vehículos | webkit | APROBADO | 0,646 |
| FORM-01 · borde: pedido sin datos no se guarda desde ADMIN | chromium | APROBADO | 7,375 |
| FORM-01 · borde: pedido sin datos no se guarda desde ADMIN | firefox | APROBADO | 8,387 |
| FORM-01 · borde: pedido sin datos no se guarda desde ADMIN | webkit | APROBADO | 15,351 |
| UX-01 · borde: login móvil 360 px y tema accesible | chromium | APROBADO | 1,876 |
| UX-01 · borde: login móvil 360 px y tema accesible | firefox | APROBADO | 3,235 |
| UX-01 · borde: login móvil 360 px y tema accesible | webkit | APROBADO | 2,419 |
| NET-01 · recuperación web después de desconectar y reconectar | chromium | APROBADO | 6,705 |
| NET-01 · recuperación web después de desconectar y reconectar | firefox | APROBADO | 7,116 |
| NET-01 · recuperación web después de desconectar y reconectar | webkit | APROBADO | 12,284 |

[Reporte Playwright HTML](playwright-html/index.html) · [JSON original](playwright-results.json) · [JUnit](playwright-junit.xml) · [Métricas/red decodificadas](metricas-navegador.json).

Los adjuntos de cada caso contienen red sanitizada, métricas y, cuando corresponde, captura de mapa/entregas o encuesta vacía. La prueba del formulario SUS utiliza selecciones sintéticas descartadas, no participantes reales.

## Capturas seleccionadas

- [chromium-mapa-Huancayo-ADMIN.png](capturas/chromium-mapa-Huancayo-ADMIN.png)
- [chromium-entregas-REPARTIDOR.png](capturas/chromium-entregas-REPARTIDOR.png)
- [firefox-mapa-Huancayo-ADMIN.png](capturas/firefox-mapa-Huancayo-ADMIN.png)
- [firefox-entregas-REPARTIDOR.png](capturas/firefox-entregas-REPARTIDOR.png)
- [webkit-mapa-Huancayo-ADMIN.png](capturas/webkit-mapa-Huancayo-ADMIN.png)
- [webkit-entregas-REPARTIDOR.png](capturas/webkit-entregas-REPARTIDOR.png)
- [chromium-encuesta-360-sin-respuestas.png](capturas/chromium-encuesta-360-sin-respuestas.png)
- [firefox-encuesta-360-sin-respuestas.png](capturas/firefox-encuesta-360-sin-respuestas.png)
- [webkit-encuesta-360-sin-respuestas.png](capturas/webkit-encuesta-360-sin-respuestas.png)
- [visual-chromium-mapa-Huancayo-ADMIN.png](capturas/visual-chromium-mapa-Huancayo-ADMIN.png)
- [visual-chromium-entregas-REPARTIDOR.png](capturas/visual-chromium-entregas-REPARTIDOR.png)
- [visual-firefox-mapa-Huancayo-ADMIN.png](capturas/visual-firefox-mapa-Huancayo-ADMIN.png)
- [visual-firefox-entregas-REPARTIDOR.png](capturas/visual-firefox-entregas-REPARTIDOR.png)
- [visual-webkit-mapa-Huancayo-ADMIN.png](capturas/visual-webkit-mapa-Huancayo-ADMIN.png)
- [visual-webkit-entregas-REPARTIDOR.png](capturas/visual-webkit-entregas-REPARTIDOR.png)
