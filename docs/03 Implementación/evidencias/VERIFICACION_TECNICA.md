# Verificación técnica del incremento

**Ejecuciones registradas:** 07 y 09/10/2026. **Corte de fuentes y documentos:** 09/10/2026. Cliente Flutter Web, FastAPI/Python 3.12 y PostgreSQL 16. El registro describe las comprobaciones técnicas realizadas y sus entornos; la aceptación académica se gestiona en la Review.

## API: 8 pruebas aprobadas

Suite: `backend/tests/test_integration.py`. Última ejecución registrada: 8 pruebas, 9.392 s, resultado OK. Base aislada `ecologistica_revision_20261007`; proveedor HTTP simulado local para el caso de rutas. La base/contenedor temporales se retiraron al finalizar.

| Caso | Resultado comprobado |
| --- | --- |
| 01 Identidad | Fallos 3/4/5 producen 5/10/300 s; plazo no se extiende; éxito reinicia. |
| 02 Concurrencia | Intentos simultáneos para identidad desconocida respetan el estado compartido. |
| 03 Sesión/roles | Token válido/vencido, usuario inactivo y permisos controlados. |
| 04 Vehículos | Alta, lectura, edición, inactivación, placa normalizada, duplicado y cero. |
| 05 Repartidores | Campos independientes, DNI/correo duplicado, horario y cuenta vinculada. |
| 06 Rutas | Aislamiento de asignaciones según el repartidor autenticado. |
| 07 Pedidos | Alta/lectura y rechazo de peso, ventana o cliente inválidos. |
| 08 Asignación/mapa | Geometría y detalle; acceso propio; duplicados, coordenadas, peso y concurrencia; proveedor falla sin asignar parcialmente. |

Los bloqueos largos se vencieron de forma controlada en identidades de prueba. El proveedor real se comprobó por separado: 57 puntos, 2.709 km y 5.52 min en el ejemplo sintético de Huancayo.

## Flutter: 27 pruebas aprobadas

`flutter test --no-pub`: All tests passed. Siete pruebas de autenticación/contador/sesión, cuatro de distribución a 360×640, 768×1024, 1440×900 y 1200×500, catorce de regresión de interfaz y dos de expansión/contracción del menú en ambos temas. `flutter analyze --no-pub`: No issues found. `flutter build web --no-pub`: construcción satisfactoria.

Las comprobaciones identifican exactamente la plataforma Web y el alcance de las pruebas; su cantidad no representa un porcentaje de cobertura.

## Navegador y persistencia

ADMIN consultó recursos y su ruta; REPARTIDOR consultó el mismo recorrido como propietario. Se verificó el mapa base cargado, origen, destino y trazado. El rechazo de campos vacíos se observó en flota. La consulta posterior confirmó los datos guardados. Las migraciones llegan a `0003_route_geometry`.

| Evidencia | Uso |
| --- | --- |
| [Resumen administrativo](resumen-app.jpg) | Consulta de registros. |
| [Validación de flota](flota-validacion.jpg) | Rechazo de formulario inválido. |
| [Ruta ADMIN](ruta-admin.jpg) | Consulta del recorrido asignado. |
| [Ruta REPARTIDOR](ruta-repartidor.jpg) | Consulta de asignación propia. |

## Reproducción

Seguir `backend/README.md` para el entorno aislado y `apps/web/README.md` para Flutter. Mantener los datos de prueba separados de operación y registrar comandos, versión, fecha y resultado de cada nueva ejecución. [Asignación y mapa](ASIGNACION_Y_MAPA.md) describe entradas, reglas y manejo del proveedor.

## Revalidación al corte documental

El 09/10/2026 se repitieron análisis, 27 pruebas Flutter, construcción Web y las 8 pruebas API en base aislada: todos aprobados. Se comprobó login y lectura de ruta por ambos roles en la base original. [Resultado del 09/10](PRUEBAS_20261009.md).

## Corte posterior de disponibilidad

La ampliación de US-004 y el traslado de US-002 a S3 se verificaron después del corte anterior: **29 pruebas Flutter y 9 API**; análisis y compilación Web correctos. Fuentes sincronizadas y base en migración 0004. [Último resultado y límites](DISPONIBILIDAD_20261009.md).
