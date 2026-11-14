> Corte histórico, 03/11/2026: web principal y Android emulado verificados; 127 backend, 81 Flutter y 90,88 % de cobertura combinada backend. Los cortes anteriores se conservan como historial. [Resultados y límites](../../docs/03%20Implementación/evidencias/20261103-estabilizacion/RESULTADOS.md).

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

El corte histórico de 58 pruebas de widgets/unidades incluyó login, formularios, temas, flota y GOLD de optimización a 360/768/1440 px. La validación Web no prueba una APK: [cliente móvil separado](../mobile/README.md). Consulta la [evidencia técnica](../../docs/03%20Implementaci%C3%B3n/evidencias/20261030/RESULTADOS.md).

## Ampliación de tráfico y reoptimización — 02/11/2026

Nuevos controles: Tráfico estimado en Rutas, Reportar incidencia de tráfico en la ruta propia, bandeja de notificaciones y comparación/aprobación de propuestas. La actualización periódica conserva avisos/versiones pendientes y se detiene al desmontar la pantalla. El formulario de asignación no se refresca mientras se edita. America/Lima se aplica a la presentación operativa. GOLD Web y pruebas (archivo histórico local del corte de Lima).


## Actualización web — 14/11/2026

Reportes incorpora indicadores de PostgreSQL, selección paginada de rutas y descarga PDF autenticada; Clientes permite alta, búsqueda, edición de estado y preferencias. El formulario de pedidos selecciona el cliente registrado sin duplicarlo y conserva su referencia. La equivalencia ambiental requiere factor, unidad y fuente; se presenta como estimación teórica.

Resultado final de esta ampliación web: 93 pruebas Flutter aprobadas, `flutter analyze` sin incidencias y compilación release desplegada. Se verificó por navegador el ciclo ADMIN → REPARTIDOR → ADMIN → REPARTIDOR con persistencia, versiones y acuse; las limitaciones por operación están en la matriz. Esta actualización no valida una APK nueva.

[Resultados](../../docs/03%20Implementaci%C3%B3n/evidencias/20261114-desarrollo-integral/RESULTADOS.md) · [Operaciones y evidencias](../../docs/03%20Implementaci%C3%B3n/evidencias/20261114-desarrollo-integral/MATRIZ_OPERACIONES.md).
