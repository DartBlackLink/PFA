# Acciones externas y condiciones de cierre

Responsable de coordinación: Jordy. Corte: 30/10/2026. Este archivo concentra las evidencias externas; no se agregan supuestos a las tablas ni se simula su realización.

| Acción | Cómo realizarla | Evidencia válida / condición de cierre |
|---|---|---|
| Confirmar compromiso y fechas de S3 | En Jira abrir EHAPP-13, revisar US-005, sprint, 13 SP y fechas del sprint. Comparar con la planificación y aprobar cualquier cambio antes de aplicarlo | Captura recortada de la historia y cabecera del sprint; registrar fecha real y corregir correspondencia documental |
| Confirmar dependencias | Revisar EHAPP-15, EHAPP-14, EHAPP-17 y EHAPP-22; decidir si se comprometen o solo apoyan el incremento | No sumar sus SP ni mover historias automáticamente; conservar la decisión del responsable |
| Capturas Jira | Capturar backlog/alcance, tablero y versión/release sin escritorio ni barras ajenas; ocultar datos privados | Imágenes legibles y recortadas, vinculadas a la fecha de revisión; no reutilizar una captura S1 como evidencia de S3 |
| Demostración del sistema | Abrir Rutas → Optimizar rutas, elegir pedidos con ventana compatible y equipos activos; generar, revisar destinos/ETA y confirmar con datos ficticios preparados | Propuesta, rechazo controlado y ruta confirmada; contrastar estado antes/después y acceso del propietario |
| Revisión real | Presentar los criterios GOLD/feliz/infeliz/borde al profesor o responsable del producto | Fecha, observación textual autorizada y decisión de aceptación. No atribuir feedback no recibido |
| SonarQube — VERIFICADO | Análisis ejecutado en ecologisticas, 30/10/2026; gate OK y cobertura 91,4 % | [Resultado, ID y límites](SONARQUBE.md). El propietario debe revocar el token compartido y usar otro localmente para futuras ejecuciones |
| Accesibilidad | Completar navegación por teclado, foco, lectura con NVDA y contraste en cada pantalla/tema; usar WAVE donde el DOM lo permita | Registro de navegador, tamaño, lector y resultado por criterio; no afirmar conformidad integral por pasar tests de widgets |
| Rendimiento integrado | Ensayar 150 pedidos/15 equipos con matriz vial representativa y medir solicitud completa, recursos y fallos | Comparación contra objetivo de 45 s. Los 7,9 s del motor no sustituyen esta prueba |
| Usabilidad con personas | Preparar tareas e instrumentos SUS/Nielsen según las guías, consentimiento y participantes reales | Respuestas reales y método; las plantillas incluidas en ZIP no son encuestas de EcoLogística |
| APK | Mantener alcance y prueba Android separados de Web | No anunciar APK lista por existir apps/mobile; compilar, instalar y probar antes de declararla entregada |
| Publicación Git | Revisar diff y exclusiones, seleccionar fuentes/documentos probados y publicar después de autorización | No subir .env/.env.example, Compose, guías internas de cierre/preparación, manifiestos locales ni revisiones auxiliares excluidas |

## Distinción de estados

**VERIFICADO:** corrección documental S1/S2, motor/API/Web, pruebas descritas y SonarQube del backend. **PARCIAL:** validación académica global y accesibilidad, con comprobaciones técnicas pero sin evaluación integral. **PENDIENTE:** confirmación formal de Jira, aceptación y las demás evidencias externas anteriores. **BLOQUEADO:** no se acredita una detención total del desarrollo; el acceso automatizado al backlog no pudo leerse. **NO APLICA a este incremento verificado:** migrar a MERN, trasladar cifras del ejemplo o atribuir una APK validada.
