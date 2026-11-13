# Cómo probar ambos roles

## Iniciar el entorno

1. Abrir Docker Desktop. En PowerShell, entrar a `D:\UC\App\ecologistica` y ejecutar `docker compose up -d` para API y PostgreSQL. No usar `down -v`: los datos deben conservarse.
2. Si la web está detenida, ejecutar `docker start ecologistica-web-principal-20261103-r3`. Abrir `http://127.0.0.1:8080/#/login`. La API responde en `http://127.0.0.1:8000/api/v1/health`.
3. Utilizar cuentas existentes. Las cuentas QA separadas de esta demostración se conservan solo en el archivo privado local `continuity-e2e.private.json`, dentro del workspace `estabilizacion_20261103`; no subir ese archivo ni copiar sus contraseñas al repositorio.

## Consultar la evidencia ya guardada

**ADMIN:** entrar en Rutas, buscar `HYO-CONT-03` y abrirla. Debe aparecer FINALIZADA, versión 2/recibida 2. Revisar las tres entregas y la hora de la primera, el reporte manual de congestión y la revisión APROBADA. El acuse debe figurar recibido. El aviso de incidencia puede seguir abierto: aprobar una replanificación no significa resolver automáticamente la congestión.

**REPARTIDOR Web:** usar otra sesión de navegador, por ejemplo `http://localhost:8080/#/login`, para no sustituir la sesión del administrador en `127.0.0.1`. Entrar como repartidor QA continuidad. En Historial aparece únicamente su recorrido, con cero activos, cero pendientes y cero versiones por recibir. Abrir mapa/detalles y cambiar entre claro/oscuro. No debe mostrar controles administrativos ni permitir modificar una entrega ya terminada.

## Repetir un recorrido nuevo

1. ADMIN registra pedidos QA nuevos con cliente, carga/peso, destino confirmado en el mapa y ventanas futuras compatibles con el turno. Verificar Huancayo y alrededores autorizados. No reutilizar ventanas vencidas del 03/11 ni modificar los registros históricos para simular una ejecución nueva.
2. Elegir conductor y vehículo disponibles. En Optimizar rutas seleccionar todos los pedidos del caso, punto de partida y hora futura; generar. Revisar que el número de entregas coincide, la capacidad y los horarios sean factibles y el mapa siga calles. Confirmar la planificación. Una vista previa sola todavía no asigna.
3. REPARTIDOR actualiza sus rutas, abre el recorrido, confirma recepción, inicia y confirma una entrega. Registrar una incidencia **simulada** de congestión con demora estimada y ubicación actual. En teléfono/emulador, solicitar GPS cuando esté detenido. Para una prueba manual sin GPS, confirmar coordenadas reales del destino; nunca colocar coordenadas inventadas para conseguir la aprobación.
4. ADMIN recibe el aviso en la campana, abre el detalle y consulta mapa/reporte. En Evaluar reoptimización confirma la posición actual del conductor y calcula. Solo deben recalcularse pendientes. Comparar el mapa y aprobar **antes de que venza la propuesta de dos minutos**. Si la alternativa no mejora la distancia, explicar la diferencia cero; no inventar ahorro.
5. REPARTIDOR espera el aviso de versión nueva: antes del acuse se verá versión 2/recibida 1. Confirmar recepción; recién entonces debe quedar 2/2 y permitir continuar. Completar pendientes y comprobar que no se duplicó la primera entrega.
6. Reiniciar únicamente `ecologistica-backend`, volver a entrar y revisar versiones, entregas e historial. No restaurar un respaldo encima de la base que contiene la demostración.

## Android

La APK debug normal está en `D:\UC\App\ecologistica\build\apk\ecologistica-huancayo-debug.apk`. Abrir un emulador Android oficial, instalarla e iniciar sesión como repartidor. `10.0.2.2` representa la computadora anfitriona **solo en el emulador**. No sirve como dirección del servidor para un teléfono físico.

Para recompilar desde D: `flutter build apk --debug --target=lib/main.dart --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1`. No distribuir APK de `integration_test` ni archivos de defines privados. Un teléfono real requiere configurar un servidor accesible, HTTPS y una firma de distribución.

## Recuperación

Ante error de red, mantener la sesión y usar Actualizar al recuperarse el servicio; comprobar que vuelve la misma ruta. Ante jornada agotada, ventana vencida o ubicación fuera del ámbito, corregir la planificación/datos de un caso nuevo: no saltarse los controles. El pedido histórico sin coordenadas necesita confirmación de su ubicación por el responsable.
