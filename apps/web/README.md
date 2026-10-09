# Cliente Web

Copia del cliente Flutter actual, con destino Web: login por rol, administración de flota/repartidores/pedidos, asignaciones y mapa; incluye la vista web de repartidor existente.

Desde esta carpeta:

```powershell
Set-Content -Path .env -Value 'API_BASE_URL=http://127.0.0.1:8001/api/v1'
flutter pub get
flutter analyze
flutter test
flutter run -d chrome --web-port 8081
# Distribución web:
flutter build web
```

Primero iniciar el backend siguiendo `../../backend/README.md`. Las credenciales son las configuradas en `backend/.env`. La API se configura en este `.env` del cliente; solo contiene la URL pública, nunca claves del servidor. No subir compilaciones ni archivos `.env`.

