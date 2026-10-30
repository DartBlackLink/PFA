# Cliente Web EcoLogística

Cliente Flutter para administración y consulta de repartidor en navegador. La Web incluye gestión de recursos/pedidos, asignación manual, planificación genética con revisión y confirmación, y consulta de recorridos. Conserva la identidad visual aprobada y temas claro/oscuro.

```powershell
flutter pub get
flutter analyze
flutter test --coverage
flutter run -d chrome --web-port 8080 --dart-define=API_BASE_URL=http://127.0.0.1:8000/api/v1
flutter build web --release --dart-define=API_BASE_URL=http://127.0.0.1:8000/api/v1
```

Inicia primero el [backend](../../backend/README.md). API_BASE_URL es un valor público de compilación; usa HTTPS al distribuir. No se carga .env ni se empaquetan claves del servidor. Para otro entorno hay que recompilar con su URL y configurar sus orígenes permitidos en la API.

Como administrador abre Rutas → Optimizar rutas, selecciona pedidos/equipos, configura salida, genera una propuesta y revisa destinos/ETA antes de confirmar. Los pedidos deben tener coordenadas y ventanas compatibles con la salida y los turnos. Generar no asigna; confirmar guarda y comprueba cambios.

Las 58 pruebas de widgets/unidades incluyen login, formularios, temas, flota y GOLD de optimización a 360/768/1440 px. La validación Web no prueba una APK: [cliente móvil separado](../mobile/README.md). Consulta la [evidencia técnica](../../docs/03%20Implementaci%C3%B3n/evidencias/20261030/RESULTADOS.md).
