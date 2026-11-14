# Matriz de pantallas, operaciones y evidencia

**Proyecto:** EcoLogística Huancayo. **Responsable:** Jordy Steve Chancasanampa Torres. **Corte técnico:** 14/11/2026, America/Lima.

APROBADO indica operación comprobada en la capa indicada. CORREGIDO indica defecto reparado y revalidado. HEREDADO indica evidencia anterior reusada sin fingir una nueva operación por navegador. La apertura de una pantalla no basta.

| Pantalla / operación | Capa y resultado | Estado |
|---|---|---|
| Login ADMIN/REPARTIDOR y sesiones concurrentes | Navegador real, roles correctos; expiración de 30 min pide nuevo login y lo permite sin eliminar seguridad. | APROBADO |
| Flota: alta/edición/estado y duplicados | Regresión de 141 pruebas backend y pruebas de widgets; edición/baja/reactivación por web del 13/11 conservadas. No se repitió un alta positiva por navegador el 14/11. | APROBADO en API / HEREDADO en UI |
| Conductores: alta/edición/turnos y cuenta | Regresión API, datos y permisos; perfil y edición web previos conservados. No se creó una nueva cuenta operativa por navegador el 14/11. | APROBADO en API / HEREDADO en UI |
| Pedidos: registro/edición/cliente/zona | Regresión API; dos pedidos QA preparados por API para el ciclo y un tercer pedido creado por formulario web, con selección del mismo cliente y referencia prellenada. Detalle leído tras recuperar los servicios: carga 1 kg, Huamanmarca, referencia y coordenadas correctas. | APROBADO: alta web/API; edición web heredada |
| Asignación manual y horario | Nuevas pruebas verifican CO₂/fuel/ETA, ventana completa y rechazo sin modificación; no se fabrican métricas en filas antiguas. | CORREGIDO |
| Clientes: registrar/buscar/editar estado | Alta por web, búsqueda, baja lógica y reactivación en 360 px; misma fila y preferencias conservadas. | APROBADO |
| Preferencias | Horario igual rechazado; 08:00–18:00, referencia y acceso guardados por web y leídos por API. | APROBADO |
| Generación genética | Botones seleccionan 2 pedidos/equipo/salida; propuesta vial de Huancayo y confirmación persistidas. | APROBADO |
| Mapa y consulta propia | Origen, paradas, primera entrega e historial por web; ajeno 404 por API. | APROBADO |
| Repartidor: acuse/inicio/entrega | Acciones por botones con confirmación; primera entrega conservada y última finaliza. | APROBADO |
| Incidencia | Reporte QA de congestión por modal; ADMIN lo recibe; resolución por web. No tráfico observado. | APROBADO |
| Reoptimización | Botones ADMIN calculan/comparan/aprueban; REPARTIDOR confirma recepción de la versión 2 y finaliza. Caso sin mejora identificado. | APROBADO |
| Resumen/indicadores | Lectura SQL, cero y ausencias diferenciados, ventanas previstas/reales; alcance de última versión explícito. | CORREGIDO |
| Reportes/PDF | Sin selección, botón deshabilitado; descarga por botón, parse y render; un error JSON/HTML no se convierte en PDF; roles protegidos. | CORREGIDO |
| Equivalencia | Factor 0 rechazado, fuente/unidad/factor guardados, división contrastada. Ausencias y casos maliciosos validados automáticamente. | APROBADO |
| Tráfico estimado: consulta | Reglas locales y fuente visibles; no tráfico en vivo. Lectura API y regresión de edición y conflictos. | APROBADO en API / HEREDADO en UI |
| Tráfico estimado: crear/editar/eliminar franja por navegador | La regresión API lo verifica; el corte del 14/11 no ejecutó el ciclo positivo completo por botones ni inventó franjas en operación. | PENDIENTE: ciclo positivo por UI |
| Temas/responsive | 93 pruebas Flutter y capturas reales de 360 px en claro/oscuro; acciones del modal visibles. No se ejecutó una auditoría integral con lector de pantalla. | APROBADO en el alcance indicado |
| Persistencia e integridad | PostgreSQL activo; consulta tras las operaciones, huellas y respaldo. | APROBADO según integridad-final.json |

Los controles no repetidos por navegador no se etiquetan como ejecutados hoy. El checklist adicional queda en el documento de acciones; estas limitaciones no se ocultan bajo un “todo al 100 %”. [Resultados](RESULTADOS.md).

Evidencia del alta web recuperada: [detalle persistido](capturas/pedido-web-persistido.jpg). [Panel final](capturas/reportes-final.jpg) y [consola de la pestaña final](browser-final.json).
