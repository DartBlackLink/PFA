# Acciones restantes — Sprint 3 y entrega

| Acción | Cómo realizarla / criterio de cierre |
|---|---|
| Análisis SonarQube de esta versión | Guardar un token vigente de `ecologisticas` en el archivo local indicado, fuera de Git. Ejecutar el análisis con cobertura de este corte, registrar analysisId y Quality Gate. No reutilizar tokens expuestos ni el 91,4 % histórico como resultado nuevo. |
| Revisión y cierre formal del Sprint 3 | Jordy contrasta fechas, compromiso y aceptación con Jira/docente. Vincular evidencia; no cambiar a Terminado solo porque compila o pasan tests. No se modificó Jira. |
| Evidencias externas de Jira | Capturar el Sprint 3 y US-005/EHAPP-13 con su compromiso/estado real; sustituir capturas únicamente después de revisar que corresponden. La ampliación Android/tráfico no se añade retroactivamente al compromiso sin decisión real. |
| Datos históricos incompletos o vencidos | Confirmar la ubicación del pedido sin coordenadas y revisar ventanas/turnos con el responsable. Conservar evidencia de los datos anteriores. No inventar ubicaciones ni cerrar el antiguo caso QA de jornada agotada como si hubiera recibido v2. |
| Distribución Android | Probar teléfono físico, permisos denegados y condiciones de GPS reales; configurar API HTTPS accesible y generar APK release firmada. La prueba actual es emulador API 36 + APK debug. |
| Repetición monolítica opcional para demostración | Crear otro fixture con horarios futuros y controlador QA local; recorrer desde cero sin interrupción. Las partes del flujo actual ya están verificadas y preservadas, pero los intentos GOLD originales fallaron antes de la continuación aprobada. No reiniciar datos para convertirlos en un pase ficticio. |
| Advertencia del cliente de pruebas | Revisar compatibilidad futura de FastAPI/Starlette/httpx antes de actualizar; el corte actual tuvo una advertencia y 127 pases. No ocultarla ni cambiar dependencias sin probarlas. |
| Alcance de Reportes | La pantalla actual es informativa y no exporta PDF. Planificar su implementación y aceptación por separado; no anunciarla como funcional. |
| Publicación | Revisar el diff de PFA con Jordy y publicar solo cuando lo autorice. Mantener excluidos .env/.env.example, Compose, claves, archivos privados, respaldos, manifiestos auxiliares y APK de instrumentación. |

No hay un bloqueo abierto en el flujo crítico comprobado ADMIN → Android → acuse → entregas → persistencia. Estas acciones delimitan validación externa, distribución y funcionalidades adicionales; el cierre Scrum no se declara automáticamente.
