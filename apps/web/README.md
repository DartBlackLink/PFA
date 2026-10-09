# Cliente Web

Copia del cliente Flutter actual, con destino Web: login por rol, administración de flota/repartidores/pedidos, asignaciones y mapa; incluye la vista web de repartidor existente.

Desde esta carpeta:

```powershell
Copy-Item .env.example .env
flutter pub get
flutter analyze
flutter test
flutter run -d chrome --web-port 8081
# Distribución web:
flutter build web
```

Primero iniciar el backend siguiendo `../../backend/README.md`. Las credenciales son las configuradas en `backend/.env`. La API se configura en este `.env` del cliente; solo contiene la URL pública, nunca claves del servidor. No subir compilaciones ni archivos `.env`.
