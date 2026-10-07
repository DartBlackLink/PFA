# Verificación técnica — 07/10/2026

Versión comprobada: fuentes locales actualizadas de EcoLogística, sin commit/push. Cliente Flutter Web, backend Python 3.12/FastAPI y PostgreSQL 16 en Docker. Es una verificación técnica; no es acta de Sprint Review ni aceptación del docente.

## API — 7/7 aprobadas

Suite: `backend/tests/test_integration.py`. Última ejecución: `Ran 7 tests in 7.443s — OK`.

| Caso | Resultado comprobado |
| --- | --- |
| 01 Login | Fallos 3/4/5: 429 con espera 5/10/300; bloqueos no se amplían; éxito reinicia intentos |
| 02 Concurrencia | Seis peticiones para identidad desconocida: dos 401, cuatro 429, sin saltarse el bloqueo |
| 03 Sesión/roles | Sesión válida/vencida, permisos y perfil propio |
| 04 Vehículos | Alta/edición/inactivación, placa normalizada, duplicado 409, cero 422 |
| 05 Repartidores | Campos independientes, duplicado, horario inválido, actualización e inactivación de acceso |
| 06 Rutas | Repartidor ve exclusivamente sus asignaciones; ADMIN consulta ambas |
| 07 Pedidos | Alta y lectura persistente; rechazo de peso cero, ventana inválida y cliente inexistente |

Base aislada: `ecologistica_revision_20261007`; contenedor `ecologistica-revision`. Se crearon datos ficticios solo allí. Los plazos largos se vencieron de forma controlada sobre identidades de prueba; no se esperaron cinco minutos reales. La base, el contenedor y la imagen temporales se retiraron al finalizar.

## Flutter — 7/7 aprobadas

`flutter test --no-pub`: All tests passed. Tres casos de bloqueo (5/10/300), persistencia del plazo, sesión vencida, restauración del rol/ logout, inicio concurrente y validación del contador/botón tras tercer fallo en pantalla 360 × 640. Los tres casos de bloqueo cuentan por separado; el total es siete pruebas.

`flutter analyze --no-pub`: No issues found. `flutter build web --no-pub`: Built build/web.

## Verificación en navegador y despliegue

- Acceso del administrador y resumen de registros desde la base principal.
- Listado y formulario de edición de repartidor con datos anteriores preservados.
- Pantalla/modal de flota; rechazo de campos vacíos sin guardar un vehículo.
- CORS corregido para los dos orígenes locales del puerto 8080.
- Consola del navegador sin errores al finalizar la revisión.
- API principal: health devuelve status=ok; Alembic indica 0002_access_resources (head); PostgreSQL saludable.

Evidencias reales: `resumen-app.jpg` y `flota-validacion.jpg`. No acreditan una demostración al docente ni cierre del Sprint.

## Límites y continuidad

No se verificó Android físico, iOS, cobertura >= 80 %, todos los criterios de accesibilidad, recuperación de contraseña ni el alcance futuro de rutas/entregas/reportes. El perfil antiguo requiere datos reales completos. Las restricciones históricas NOT VALID requieren auditoría adicional. Consulta `D:\UC\App\ecologistica\CAMBIOS_Y_PENDIENTES.md` y la guía documental de PFA.
