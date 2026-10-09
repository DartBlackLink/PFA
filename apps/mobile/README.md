# Cliente móvil — fuentes Android/iOS

Esta carpeta copia el código Flutter disponible y las plataformas Android/iOS del proyecto original. Es una base de desarrollo separada, no una APK terminada ni certificada. Conserva temporalmente los módulos compartidos de la web para no perder código; aún falta especializar navegación, diseño y pruebas exclusivamente para REPARTIDOR.

## Preparación Android

```powershell
Set-Content -Path .env -Value 'API_BASE_URL=http://10.0.2.2:8000/api/v1'
flutter pub get
flutter analyze
flutter test
flutter devices
flutter run -d ID_DEL_DISPOSITIVO
# Cuando se hayan validado el cliente y el SDK Android:
flutter build apk --debug
```

La configuración de ejemplo usa el emulador Android. En un teléfono físico, configurar la IP accesible del backend y su exposición de red; 127.0.0.1 dentro del teléfono no corresponde al PC. El arranque de ejemplo del backend expone la API solo localmente. Revisar permisos de internet/política HTTP para pruebas y usar HTTPS al distribuir.

La aceptación en dispositivo comprende navegación de repartidor, login y bloqueo 5/10/300 s, sesión y rutas propias, mapa, permisos y generación de APK. Su seguimiento se gestiona en el registro local de acciones de entrega. iOS requiere macOS/Xcode. No se ha generado ni probado una APK en esta copia.


Fuentes compartidas sincronizadas el 09/10/2026. Las pruebas automatizadas Flutter verifican el código compartido; la ejecución acreditada del producto corresponde a Web/API.
