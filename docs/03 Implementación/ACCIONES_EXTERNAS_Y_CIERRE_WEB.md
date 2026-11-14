# Acciones externas y cierre de la web

**Proyecto:** EcoLogística Huancayo. **Responsable:** Jordy Steve Chancasanampa Torres. **Corte técnico:** 14/11/2026, America/Lima.

Este es el registro común para evitar mensajes repetidos de “pendiente” en formularios del producto. Las limitaciones necesarias para interpretar un indicador sí se muestran en la interfaz.

| Acción | Qué falta exactamente | Cómo resolverlo | Impide ejecutar la web |
|---|---|---|---|
| Jira | Solo existen sprints 1, 2 y 3; 4, 5 y 6 son agrupaciones documentales propuestas. S1 sigue activo y S2/S3 futuros aunque haya código verificado. | Responsable/docente confirman alcance, fechas y SP; crear/organizar sprints sin inventar reuniones, conservar historia y adjuntar evidencia; cambiar estados solo tras aceptación. No se hizo desde esta tarea. | No |
| Review y retrospectiva reales | Decisión de aceptación/feedback y compromisos del responsable. | Demostrar cada criterio con su evidencia, registrar asistentes/fecha/decisión reales; confirmar compromisos preventivos. | No |
| SonarQube | Falta credencial privada vigente; no hay análisis nuevo de esta versión. | Guardar token seguro fuera de PFA/D y ejecutar análisis con cobertura XML final. No reutilizar los publicados en chat. | No; bloquea únicamente ese análisis |
| Rendimiento ampliado | Una semilla 42, 150/15 con 3 destinos repetidos y replan3 pendientes; no la campaña de 5 semillas ni peor caso. | Acordar protocolo final; ampliar muestra, semillas y rutas con caché frío/caliente y proveedor autorizado. Conservar fallos; no extrapolar 16,65 s como SLA universal. | No; condiciona el cierre del protocolo ampliado |
| Accesibilidad formal | No se ejecutó auditoría completa WCAG ni lector de pantalla. | Recorrer tareas por teclado/lector, zoom y tamaños acordados, registrar por criterio; las capturas y 93 pruebas de widgets no equivalen a certificación. | No; no declarar certificación |
| Verificación UI adicional | No se repitieron el alta positiva de flota/conductor ni el CRUD positivo completo de franjas de tráfico por navegador en este corte; existe regresión API y evidencia anterior. | Ejecutar los ciclos con datos QA identificados y registrar pantalla, petición y persistencia. No afirmar que fueron repetidos hoy. | No; condiciona la afirmación de cobertura UI integral |
| Verificación UI adicional | No se repitieron el alta positiva de flota/conductor ni el CRUD positivo completo de franjas de tráfico por navegador en este corte; existe regresión API y evidencia anterior. | Ejecutar los ciclos con datos QA identificados y registrar pantalla, petición y persistencia. No afirmar que fueron repetidos hoy. | No; condiciona la afirmación de cobertura UI integral |
| Android | Esta intervención es web. No se creó ni se validó una APK nueva con estos cambios. | Si se requiere entrega móvil, planificar su verificación separada, firma, dispositivo y evidencias propias. | No |
| Publicación | Cambios locales preparados; no commit/push en esta tarea. | Revisar PFA, matriz, evidencias y escaneo; publicar solo con autorización. | No |

No se presentan estas acciones como defectos funcionales inexistentes ni como impedimentos múltiples. [Matriz de aceptación](MATRIZ_FINAL_BACKLOG_WEB.md).
