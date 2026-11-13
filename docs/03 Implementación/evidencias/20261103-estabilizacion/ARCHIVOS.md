# Archivos de código y pruebas de esta estabilización

14 fuentes distintas: las 13 de la primera sincronización y una nueva prueba de continuación. Fuentes finales comparadas por SHA en D y PFA. Las actualizaciones posteriores de los tests conservan respaldos independientes.

| Ruta respecto de la raíz Flutter activa | Destino en PFA |
|---|---|
| `lib/core/location/current_location.dart` | `apps/web/lib/core/location/current_location.dart` y `apps/mobile/lib/core/location/current_location.dart` |
| `lib/core/location/location_native.dart` | `apps/web/lib/core/location/location_native.dart` y `apps/mobile/lib/core/location/location_native.dart` |
| `lib/core/widgets/record_widgets.dart` | `apps/web/lib/core/widgets/record_widgets.dart` y `apps/mobile/lib/core/widgets/record_widgets.dart` |
| `lib/features/auth/presentation/screens/courier_workspace.dart` | `apps/web/lib/features/auth/presentation/screens/courier_workspace.dart` y `apps/mobile/lib/features/auth/presentation/screens/courier_workspace.dart` |
| `lib/features/auth/presentation/screens/repartidor_screen.dart` | `apps/web/lib/features/auth/presentation/screens/repartidor_screen.dart` y `apps/mobile/lib/features/auth/presentation/screens/repartidor_screen.dart` |
| `lib/features/rutas/presentation/operational_route_map.dart` | `apps/web/lib/features/rutas/presentation/operational_route_map.dart` y `apps/mobile/lib/features/rutas/presentation/operational_route_map.dart` |
| `lib/features/rutas/presentation/route_detail_screen.dart` | `apps/web/lib/features/rutas/presentation/route_detail_screen.dart` y `apps/mobile/lib/features/rutas/presentation/route_detail_screen.dart` |
| `test/courier_workspace_test.dart` | `apps/web/test/courier_workspace_test.dart` y `apps/mobile/test/courier_workspace_test.dart` |
| `test/route_map_lifecycle_test.dart` | `apps/web/test/route_map_lifecycle_test.dart` y `apps/mobile/test/route_map_lifecycle_test.dart` |
| `integration_test/courier_gold_test.dart` | `apps/web/integration_test/courier_gold_test.dart` y `apps/mobile/integration_test/courier_gold_test.dart` |
| `integration_test/courier_resume_test.dart` | `apps/web/integration_test/courier_resume_test.dart` y `apps/mobile/integration_test/courier_resume_test.dart` |
| `android/app/src/main/AndroidManifest.xml` | `apps/mobile/android/app/src/main/AndroidManifest.xml` |
| `android/app/src/main/kotlin/com/example/ecologistica/MainActivity.kt` | `apps/mobile/android/app/src/main/kotlin/com/example/ecologistica/MainActivity.kt` |
| `integration_test/courier_receive_test.dart` | `apps/web/integration_test/courier_receive_test.dart` y `apps/mobile/integration_test/courier_receive_test.dart` |

Las mismas fuentes se mantienen en D:/UC/App/ecologistica. El backend no recibió cambios de código en este corte: se desplegaron las migraciones aditivas existentes 0006/0007 y se ejecutó de nuevo su regresión completa.

Documentación: cuatro archivos del Sprint 3 y esta carpeta de evidencias; README de los clientes actualizado. Los documentos de Sprints 1 y 2 y las evidencias anteriores se conservan.

No se copia a Git configuración privada, Compose, respaldos de base, tokens, controladores efímeros, manifiestos auxiliares ni APK de instrumentación. La APK normal se entrega localmente en build/apk. No se hizo commit/push ni se alteró Jira.
