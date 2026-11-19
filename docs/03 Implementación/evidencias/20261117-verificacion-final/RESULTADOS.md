# Verificación funcional final de la WEB — 17/11/2026

**Proyecto:** EcoLogística Huancayo. **Responsable:** Jordy Steve Chancasanampa Torres. **Zona horaria:** America/Lima.

## Resultado y alcance

El ciclo operativo ADMIN → REPARTIDOR → ADMIN → REPARTIDOR se completó por navegador con FastAPI y PostgreSQL activos: generación y confirmación, recepción e inicio, primera entrega, incidencia QA, evaluación y aprobación de una nueva versión, recepción efectiva y última entrega. La API confirmó FINALIZADA, versión 2 recibida, dos entregas y una incidencia resuelta.

Se comprobaron los campos y operaciones indicados en la [matriz por apartado](MATRIZ_OPERACIONES.md). No se identificó un fallo funcional abierto en esos casos después de las correcciones. Esto no garantiza ausencia de cualquier error posible ni sustituye aceptación académica, pruebas de carga ampliadas o auditoría de accesibilidad. La revisión corresponde a la web; no se compiló ni comprobó Android.

## Errores encontrados y corregidos

| ID | Reproducción y causa | Corrección | Comprobación |
|---|---|---|---|
| WEB-1711-01 | En Tráfico estimado, editar factor a 0 y guardar cerraba el modal; el servidor rechazaba correctamente con 422, pero el usuario recibía un mensaje técnico. El formulario solo comprobaba que fuese un número. | Se validan factor 1–5, minutos, orden de horarios y límites de Huancayo antes de cerrar. Los campos se conservan con mensajes en español. No se redujeron controles del servidor. | Ocho regresiones nuevas: no escritura ante datos inválidos; [captura del formulario desplegado](trafico-corregido.jpg). |
| WEB-1711-02 | La ruta inicial tomaba el color primario claro del tema oscuro, que se confundía con calles y fondo de OpenStreetMap. La geometría sí estaba guardada (164 puntos). | Trazado inicial azul con borde blanco; se conserva verde para alternativa y rojo para comparación. No se cambiaron coordenadas ni cálculos. | Dos regresiones de contraste para ambos temas y revisión del [mapa final](mapa-final-corregido.jpg). La prueba de contraste usa un fondo claro representativo, no certifica todos los píxeles/cartografías. |

Código: [formulario de tráfico](../../../../apps/web/lib/features/rutas/presentation/traffic_policy_screen.dart), [mapa](../../../../apps/web/lib/features/rutas/presentation/operational_route_map.dart), [regresión de validación](../../../../apps/web/test/traffic_policy_validation_test.dart) y [regresión del mapa](../../../../apps/web/test/route_map_lifecycle_test.dart).

## Pruebas ejecutadas en este corte

| Control | Resultado | Evidencia |
|---|---|---|
| Backend, PostgreSQL QA aislado | 141 aprobadas, 889 advertencias, 79,13 s; sin cambios backend en esta revisión. | [Log](backend-full.log), [JUnit](test-results.xml) |
| Cobertura backend | 90.0313479624 % combinada de líneas y ramas: 2872/3190. Líneas 2321/2492; ramas 551/698. Umbral 81 % conservado. | [XML](coverage.xml), [HTML](htmlcov/index.html) |
| Flutter final | 103 aprobadas: 93 anteriores + 8 de tráfico + 2 de contraste. | [Log](flutter-final.log) |
| Analizador Flutter | No issues found, 4,9 s. | [Log](flutter-analyze-final.log) |
| Compilación release web | Compilada y desplegada; hash del JavaScript servido comprobado. Solo se actualizó el servicio web existente. | [Build](build-web-final.log), [despliegue](deployment.json) |
| Casos API directos | 78 etiquetas de comprobación distintas; el registro incluye repeticiones al corregir datos del instrumento. No se suman como 126 casos únicos. | [Casos](casos-api.json), [peticiones sin credenciales](runtime-api.jsonl) |
| Persistencia e integridad | Filas originales de negocio conservadas en las 19 tablas del respaldo. Sin reinicializar ni restaurar la base. | [Integridad](integridad-final.json), [flujo](flujo-final.json) |
| PDF real | Descargado mediante el botón web; pypdf comprobó una página con la ruta correcta y Huancayo. | [Descarga web](descarga-web.pdf), [captura](pdf-descargado.jpg) |
| Consolas finales | Sin errores/advertencias capturados en las dos pestañas consultadas. | [Registro](browser-logs.json) |

### Ejecución y entorno

El backend se ensayó con `python -m pytest backend/tests -p no:cacheprovider --cov=backend/app --cov-config=.coveragerc`, salidas JUnit/XML/HTML y credenciales QA privadas. El esquema `revision_final_20261117` pertenece a la base de pruebas existente; no se ejecutó el fixture contra la base operativa.

En la raíz de desarrollo se ejecutaron `flutter test --concurrency=1 --reporter expanded`, `flutter analyze` y `flutter build web --release --output build/web-review-final-20261117 --dart-define=API_BASE_URL=http://127.0.0.1:8000/api/v1`. Los logs y hashes identifican el resultado real. No se ejecutó un análisis SonarQube nuevo en esta revisión ni se atribuye a esta versión un resultado histórico.

## Datos utilizados y observaciones

- Se conservó el respaldo privado de la base activa. Se añadieron únicamente registros sintéticos identificados: un cliente, un repartidor/cuenta QA, un vehículo, tres pedidos, una ruta y su incidencia. La franja QA se creó, editó y retiró con autorización expresa; la política quedó de nuevo sin reglas, con revisión 3.
- Dos pedidos QA finalizaron en la ruta; el tercer pedido se registró y editó por el formulario y queda PENDIENTE, con peso 2 kg y prioridad ALTA. Totales al cierre: 27 pedidos, 21 vehículos, 11 repartidores y 16 rutas. Las credenciales QA y los dumps permanecen fuera del repositorio.
- La búsqueda web de Plaza Huamanmarca devolvió el punto de Photon/OSM y se confirmó manualmente. El destino de Parque de la Identidad se contrastó con el punto público previamente registrado antes de confirmar la propuesta válida. Los datos de simulación no representan envíos ni tráfico observados.
- La alternativa calculada resultó 0,35 km y 0,35 min mayor bajo esta estimación. La interfaz lo informó; se aprobó para comprobar el cambio de versión en el escenario QA. No se declara ahorro ni óptimo global.
- La sesión ADMIN venció durante un intento de descarga; se renovó con normalidad y se repitió la operación. El botón también necesitó desplazamiento para quedar visible en el navegador. El PDF finalmente descargado se comprobó; esos intentos de automatización no se registran como una caída de FastAPI.
- El instrumento local se corrigió al comprobar que una latitud de prueba todavía pertenecía a Huancayo y al leer su archivo de estado explícitamente como UTF-8. Se corrigieron solo datos QA; no se atribuyen esos errores del instrumento al sistema.

## Límite del cierre

Los escenarios detallados permiten dar por verificada la operación principal y las correcciones de esta versión web. El alta de la cuenta del nuevo repartidor se probó por API; por navegador se probaron sus obligatorios, edición, baja, reactivación y acceso. No se presenta ese alta positiva como una nueva contraseña enviada por la interfaz. La prueba completa con lector de pantalla, la campaña ampliada de rendimiento y el análisis SonarQube siguen siendo controles separados. No se cambiaron estados Jira ni se publicó en GitHub desde esta revisión.
