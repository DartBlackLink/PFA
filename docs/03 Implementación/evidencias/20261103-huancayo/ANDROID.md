# Android — intento real del 03/11/2026

**Resultado: no validado funcionalmente en esta versión.** No se suma ningún caso nativo aprobado a las 73 pruebas Flutter. Las dos aprobaciones del 02/11 pertenecen al checkpoint anterior.

Se inició Pixel_10a en modo read-only, sin snapshots, sin borrar datos del AVD; puerto5580, API37, 1536MB,2núcleos, tamaño480×800. ADB reverse8002 apuntó exclusivamente a FastAPI QA Huancayo. El caso courier_traffic_test.dart mantiene las comprobaciones de ruta propia, versión 2, recibida 2, tres pedidos únicos entregados e historial. Se parametrizó la placa HYO-QA-03 sin reducir aserciones.

1. El primer lanzador PowerShell abortó ante una advertencia Java enviada a stderr. Se corrigió para respetar el código de salida real del proceso; el registro inicial se conserva.
2. Un intento posterior compiló pero no pudo instalar por `Can't find service: package`.
3. Cuando `service check package` respondió found, se reintentó. El APK compiló en24,4s; el lanzamiento falló con Activity class does not exist. La inspección AAPT confirmó que el APK declara `com.example.ecologistica.MainActivity` y el código/manifest corresponden a esa actividad. Consultas ADB posteriores volvieron a mostrar ausentes package y activity.
4. Logcat registró `DeadSystemException: The system died` en procesos del sistema/Google, antes de ejecutar las aserciones de la aplicación. No se atribuye una causa raíz específica (memoria, imagen o hipervisor) que el registro no demuestre. Se pausó Sonar temporalmente para aliviar recursos, sin conseguir una ejecución válida; se restauró al finalizar.

Comando: `flutter drive --driver=test_driver/integration_driver.dart --target=integration_test/courier_traffic_test.dart -d emulator-5580 --dart-define-from-file=<archivo QA privado>`. API_BASE_URL=127.0.0.1:8002/api/v1, QA_PLATE=HYO-QA-03. No se adjuntan claves ni APK de instrumentación.

Para continuar: usar un dispositivo físico autorizado o un emulador QA estable y esperar disponibilidad real de package/activity, no solo sys.boot_completed. Repetir el caso de consulta y luego GOLD móvil completo con pérdida/recuperación de señal. No borrar ni restaurar de fábrica el AVD original como solución automática. Esta limitación impide declarar verificada la APK actual.
