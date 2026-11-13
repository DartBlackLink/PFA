# Verificación funcional de EcoLogística Huancayo

Pruebas web del 4 de noviembre y continuación del 8 de noviembre de 2026. La imagen final atendió una base QA aislada. Al terminar, la API operativa volvió a su puerto y las cantidades y huellas de todas las tablas coincidieron con el inicio.

| Módulo | Resultado observado |
| --- | --- |
| Acceso y permisos | Login ADMIN y REPARTIDOR, cierre de sesión web del repartidor, bloqueos 5, 10 y 300 s en una cuenta sintética, rechazo 401 sin sesión y 403 por rol. Otro repartidor recibió 404 al consultar o iniciar la ruta. |
| Resumen | Panel web y conteos con datos QA. |
| Vehículos y repartidores | Altas, consulta, edición e inactivación en navegador. Reactivación, duplicados, validaciones y paginación por API. La inactivación denegó el ingreso al repartidor. |
| Pedidos y mapa | Alta, búsqueda y detalle en navegador, búsqueda Photon y selección de un punto de Huancayo. API verificó campos, ventana, peso y rechazo de coordenadas de Lima. El módulo ofrece alta y consulta. |
| Tráfico | Alta y retiro de franja estimada en web, lectura persistente, rechazo de factor inválido y revisión obsoleta. |
| Rutas e integración | Vista previa y mapa en web. Flujo de escrituras del 8 de noviembre por API con PostgreSQL y red vial real. Generación, asignación, inicio, primera entrega, aviso de congestión, propuesta de dos pendientes, aprobación, acuse de versión 2 y cierre de tres entregas. |
| Historial del repartidor | Consulta en navegador con filtro Historial, versión 2 recibida y ruta finalizada. Tras reiniciar la API QA coincidieron las entregas y las revisiones. |
| Reportes | Pantalla informativa. Exportación PDF pendiente. |

La ruta QA `e8660d44-3e66-41cb-924c-0f2e1779d9ab` conservó la fecha de la primera entrega. Una entrega fuera de secuencia y otra antes del acuse recibieron 409. Se comprobó también la resolución de la incidencia. Los destinos son públicos y las entregas fueron simuladas.

Se corrigió la etiqueta que mostraba «recibida» en una propuesta aún sin asignar. La fuente en D y las copias Web y móvil en PFA contienen el cambio. La imagen Docker que está sirviendo la web queda pendiente de actualización.

**Resultados.** 82 comprobaciones HTTP y cinco intentos del escenario de bloqueo aprobaron. Flutter pasó 8 pruebas focalizadas y 81 en la regresión completa. Las 127 pruebas backend y el 90,88 % de cobertura corresponden al corte anterior. El código backend no cambió en este corte.

**Pendientes.** Recorrer en navegador los botones de asignación manual y edición de horario, y el ciclo interactivo completo de incidencia y reoptimización. En esta continuación, las escrituras de ese ciclo se verificaron por API. Android físico y recuperación de conexión requieren verificación actual. Sonar conserva el resultado documentado de la consolidación. El cierre académico sigue parcial.
