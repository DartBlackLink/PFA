> Estado vigente, 03/11/2026: web principal y Android emulado verificados; 127 backend, 81 Flutter y 90,88 % de cobertura combinada backend. Los cortes anteriores se conservan como historial. [Resultados y límites](../../docs/03%20Implementación/evidencias/20261103-estabilizacion/RESULTADOS.md).

# Cliente Flutter para Android — base compartida actualizada

Fuentes alineadas con la aplicación activa el 02/11/2026. Usa la misma autenticación, API y autorización por recurso. Al ingresar como REPARTIDOR muestra su operación y sus rutas; no existe un sistema de usuarios paralelo. La base conserva componentes compartidos de administración; la especialización y distribución exclusiva del cliente móvil se revisan por separado.

```powershell
flutter pub get
flutter analyze
flutter test
flutter run -d ID_DISPOSITIVO --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1
flutter build apk --debug --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1
```

10.0.2.2 representa el host en el emulador Android. Con un túnel ADB local, usar `adb reverse tcp:8000 tcp:8000` y API_BASE_URL=http://127.0.0.1:8000/api/v1. HTTP se permite solo para destinos locales en debug; distribuir requiere HTTPS y firma de entrega. No se carga .env como asset.

La APK debug compiló; la prueba nativa de acceso/consulta no está aprobada. Estado y reproducción Android (archivo histórico local del corte de Lima). La prueba completa de operación corresponde a Web/API. iOS requiere macOS/Xcode y no fue probado.

Para integration_test/courier_real_test.dart usar exclusivamente la API QA y un archivo privado con API_BASE_URL, QA_EMAIL y QA_PASSWORD. No incorporar cuentas reales ni credenciales a los archivos versionados. No versionar APK de instrumentación ni sus defines privados.

## Verificación nativa posterior — 02/11/2026

La consulta Android que no estaba aprobada en el checkpoint anterior se repitió satisfactoriamente: dos casos nativos comprobaron acceso/ruta propia y versión 2 recibida con tres entregas persistentes. Esto no acredita el GOLD móvil completo ni GPS nativo. No distribuir las APK de instrumentación con defines QA. Resultado nativo y comandos (archivo histórico local del corte de Lima).
