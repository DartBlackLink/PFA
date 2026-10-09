# Revisión de interfaz y pruebas — 09/10/2026

Aplicación revisada: `D:\UC\App\ecologistica`. Esta revisión corresponde a la web y su API local. Las fuentes y evidencias se sincronizaron con PFA el 09/10/2026 para verificar la entrega. No se publicaron estos cambios en GitHub.

## Cambios realizados

- Tema central para ambos roles: superficies diferenciadas, textos legibles, bordes visibles, campos, selectores, tablas y ventanas modales consistentes en modo claro y oscuro. Se retiraron colores fijos que dejaban textos oscuros sobre fondos oscuros en Flota y el fondo claro fijo del acceso.
- Pedidos, repartidores y vehículos presentan tablas en áreas de al menos 850 px y tarjetas en espacios menores. Las tablas conservan sus columnas con desplazamiento horizontal cuando sea necesario.
- Panel con accesos directos a registrar pedidos, organizar rutas y consultar el equipo; resumen construido con los registros existentes.
- Pedidos con estados visibles, fechas locales legibles y ventana de detalle con cliente, dirección, carga, referencia, coordenadas y horario.
- Modales con encabezado, explicación breve, campos agrupados y contenido desplazable. El formulario de vehículo apila sus campos en pantallas pequeñas y mantiene accesibles Guardar y Cancelar.
- Vehículos y coordenadas del repartidor aceptan decimales escritos con punto o coma. Las validaciones de longitud de cliente, dirección y producto se ajustaron al contrato de la API.
- Repartidor con cambio de tema, estados y nombres de recorridos comprensibles, sin mostrar identificadores internos como título.
- Mapa con controles de acercar, alejar y centrar el recorrido. La rueda no cambia accidentalmente el zoom al recorrer la página. Se añadió un límite de espera de 12 segundos a las solicitudes de teselas, aviso de error y reintento del fondo de calles. El mapa y sus atribuciones conservan su legibilidad.

## Verificación realizada

| Verificación | Resultado y alcance |
| --- | --- |
| `flutter analyze` | Sin incidencias en la versión final. |
| `flutter test` | 27 pruebas aprobadas: las 11 existentes, 14 de regresión de interfaz y 2 de menú lateral. |
| Pruebas nuevas de UI | Contraste de texto normal y secundario, campos y estados; acceso, formularios de vehículos y tabla/tarjeta en ambos temas a 360 × 640 y 1440 × 900; validación de campos vacíos y persistencia correcta de decimales con coma en el proveedor simulado. |
| `flutter build web` | Compilación final correcta. |
| API en entorno aislado | 8 pruebas aprobadas. Base temporal retirada al terminar, sin modificar la base original. |
| Cobertura funcional de la suite API | Acceso y bloqueos progresivos de 5/10/300 segundos, concurrencia, sesiones y permisos por rol; vehículos; repartidores y desactivación; pedidos y persistencia; asignación de rutas, aislamiento por propietario y error del proveedor de recorrido. El proveedor vial se simula en esta suite para obtener resultados repetibles. |
| API local real | Salud correcta, acceso correcto de administrador y repartidor, consulta de registros, perfil propio y detalle de la ruta existente con una entrega y 57 puntos de geometría. |
| Navegador | Inicio de sesión de ambos roles, navegación administrativa, búsqueda de pedidos, selección de prioridad, rechazo de formularios incompletos, edición de repartidor sin guardar cambios, formulario de vehículo y tarjetas móviles; consulta del recorrido como administrador y repartidor. |
| Mapa real | Fondo OpenStreetMap, origen, destino y trazado visibles; controles de zoom y centrado comprobados con el repartidor. |

Las pruebas de contraste comprueban un mínimo de 4,5:1 para las combinaciones ensayadas. No equivalen a una auditoría integral de accesibilidad o a un porcentaje de cobertura de todo el sistema. Posteriormente se cargó el conjunto ficticio solicitado: 6 vehículos, 6 repartidores, 20 pedidos y 20 rutas distintas; véase [datos de prueba](DATOS_DE_PRUEBA_20261009.md).

## Capturas

- [Pedidos en modo oscuro](ui_20261009/pedidos_oscuro.png).
- [Modal de vehículo en pantalla pequeña](ui_20261009/modal_vehiculo_movil_oscuro.png).
- [Repartidor en pantalla pequeña](ui_20261009/repartidor_movil_oscuro.png).
- [Mapa con calles y recorrido verificados](ui_20261009/ruta_final.png).

## Mejoras finales incluidas

- Separación de 12 px entre Inicio y Fin del pedido.
- Menú lateral con superficies del tema, expansión a 248 px y contracción a 80 px; navegación y estado seleccionado comprobados en ambos temas.
- [Menú expandido](ui_20261009/menu_expandido_oscuro.png), [menú contraído](ui_20261009/menu_contraido_oscuro.png) y [panel con datos de prueba](ui_20261009/panel_con_datos.png).

La preparación académica, las capturas de Jira/Figma y los controles de aceptación se gestionan en el documento local de acciones de entrega. Los resultados acreditados aquí corresponden a API y Web; la carpeta móvil conserva fuentes Android/iOS compartidas, sin atribuir una prueba de APK a esta ejecución.

## Corte posterior de disponibilidad

La ampliación de US-004 y el traslado de US-002 a S3 se verificaron después del corte anterior: **29 pruebas Flutter y 9 API**; análisis y compilación Web correctos. Fuentes sincronizadas y base en migración 0004. [Último resultado y límites](DISPONIBILIDAD_20261009.md).
