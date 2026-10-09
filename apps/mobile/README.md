# Base del cliente móvil — APK pendiente

Esta carpeta copia el código Flutter disponible y las plataformas Android/iOS del proyecto original. Es una base de desarrollo separada, no una APK terminada ni certificada. Conserva temporalmente los módulos compartidos de la web para no perder código; aún falta especializar navegación, diseño y pruebas exclusivamente para REPARTIDOR.

## Preparación Android

```powershell
Set-Content -Path .env -Value 'API_BASE_URL=http://10.0.2.2:8001/api/v1'
flutter pub get
flutter analyze
flutter test
flutter devices
flutter run -d ID_DEL_DISPOSITIVO
# Cuando se hayan validado el cliente y el SDK Android:
flutter build apk --debug
```

La configuración de ejemplo usa el emulador Android. En un teléfono físico, configurar la IP accesible del backend y su exposición de red; 127.0.0.1 dentro del teléfono no corresponde al PC. El arranque de ejemplo del backend expone la API solo localmente. Revisar permisos de internet/política HTTP para pruebas y usar HTTPS al distribuir.

Pendientes: cliente exclusivo de repartidor, validación del login y bloqueo 5/10/300 s en dispositivo, sesión y rutas propias, mapa en Android, permisos, pruebas y generación de APK. iOS requiere macOS/Xcode. No se ha generado ni probado una APK en esta copia.

