# Matriz de aceptación del Sprint 3 — 04/11/2026

**APROBADO significa evidencia técnica comprobada; no aceptación del Product Owner ni del profesor.** Fuente actual: consulta Jira autenticada exportada en [jira-scope.json](jira-scope.json). Código sin cambios frente a las suites conservadas.

## Criterios textuales de US-005 / EHAPP-13

| ID y condición de aceptación | Prueba/evidencia específica | Dictamen |
|---|---|---|
| C1. Con pedidos, vehículos y conductores elegibles, el algoritmo devuelve rutas que respetan restricciones obligatorias | `test_gold_preview_confirm_consult_and_owner_routes`, casos de capacidad, ventanas, pausas/turno y motor incluidos en JUnit 127. Nuevo flujo Web principal: tres pedidos de 2 kg, vehículo de 30 kg, conductor disponible, destinos de Huancayo, propuesta genética 7,469 km/ETA/estimaciones, confirmación separada y cada pedido una vez. Capturas 01/02; before/after-restart.json. | **APROBADO técnico** |
| C2. Ante demanda/restricciones inviables, informa ausencia de solución factible y no presenta una inválida como correcta | `test_unhappy_capacity_no_false_feasible_route`, `test_unhappy_capacity_window_provider_and_invalid_resources`. JUnit vigente sin fallos; fuente backend idéntica. La UI sigue mostrando diagnósticos de ubicación ausente y ventana vencida en datos históricos, sin moverlos para aprobar. No se confunde error 503 de proveedor con prueba de inviabilidad matemática. | **APROBADO técnico** |

[Nombres comprobados en JUnit](acceptance-test-names.json) · [JUnit vigente](../20261103-estabilizacion/test-results.xml).

## GOLD, feliz, infeliz y borde de la revisión docente

| Ruta/criterio derivado | Resultado y alcance | Dictamen |
|---|---|---|
| GOLD Web principal completo | Generación → mapa → asignación → recepción/inicio → primera entrega → incidencia manual → aviso ADMIN → comparación → aprobación v2 → acuse Web 2/2 → tres entregas → reinicio API y recarga cliente. Ruta f95beaed-6a52-4905-8cd8-c468ce19ddae. | **APROBADO**, ejecución nueva 04/11 |
| Feliz: conservación antes de confirmar | La propuesta se revisa antes de asignar; asignación confirmada y lista propia visible. Se conserva la política de previsualización y transacción probada en backend. | **APROBADO** |
| Infeliz: acceso indebido | API principal: sin sesión 401, flota con REPARTIDOR 403 y ruta de otra identidad 404; listado solo de su propietario. permission-checks.json. | **APROBADO**, comprobación nueva |
| Borde: duplicados/concurrencia | `test_confirmation_is_idempotent_under_concurrency` vigente; tres pedidos únicos en el caso nuevo. | **APROBADO** |
| Borde: datos cambiados/propuesta vencida | `test_stale_preview_cannot_change_orders_or_create_partial_routes[order/capacity/shift]`, `test_expired_plan_rejected_and_preview_consultable`. | **APROBADO**, suite vigente |
| Borde: versión y primera entrega | `test_gold_versions_keep_completed_deliveries_and_require_receipt`; caso nuevo muestra 2/1 antes del acuse y 2/2 después. Primera entrega conserva su fecha exacta tras replan y reinicio. | **APROBADO** |
| Persistencia y navegación | after-restart.json coincide con ruta/incidencia/revisiones de before-restart.json; dos casos anteriores intactos y recarga del navegador correcta. | **APROBADO** |
| Responsive y temas | Suites Flutter 81: 360/768/1440, claro/oscuro y texto ampliado; revisión real Web previa 360 y nueva ejecución Web a 1280×720. No se reejecutó toda la suite ni se inventa pase de lector de pantalla. | **APROBADO en alcance probado** |

## Condiciones académicas y adicionales que no se confunden con C1/C2

| Requisito/fuente | Evidencia disponible y carencia | Dictamen |
|---|---|---|
| Cuatro entregables S3/plantilla docente | Estado, Impedimentos, Revisión y Retrospectiva separados en Sprint 3; historial preservado y adenda actual vinculada. Informe exclusivo de S3, impedimentos separados de defectos y acciones preventivas propuestas. | **APROBADO documental**, sujeto a evaluación docente |
| Trazabilidad Jira/periodo | Una historia/13 SP en Sprint 3 futuro; informe técnico no altera fechas oficiales ni declara ceremonia o aceptación. Adenda identifica el anterior S3 de 22 SP como histórico. | **PARCIAL**: conciliación expuesta; aceptación/calendario administrativo pendiente |
| Cobertura backend >80 % | XML real 2261/2410 líneas y 478/604 ramas: combinada 90,87591240875912408759124088 %. Flutter no está incluido en esa cifra. | **APROBADO técnico** |
| SonarQube de versión actual, cronograma TP_2 16 p.2 | Proyecto ecologisticas2.1; tarea SUCCESS, gate OK, cobertura90,9 %, incidencias abiertas0. [Resultado y límites](SONARQUBE_ACTUAL.md). | **APROBADO técnico** |
| WCAG/accesibilidad, cronograma TP_2 16 p.2 | Pruebas de componentes/tema/semántica y revisión visual disponibles; falta evaluación manual integral de teclado y lector con criterios/resultados. | **PARCIAL** |
| OWASP, cronograma TP_2 16 p.2 | Roles/recursos, validación, ORM, límites y pruebas existentes; Bandit/pip-audit previos y permisos nuevos. Falta completar el alcance documentado de revisión, sin presentarlo como pentest completo. | **PARCIAL** |
| RNF-01 global, consigna p.2 | Benchmark del motor con matriz controlada, no medición integrada 150/15 con red/PostgreSQL ≤45 s. No se exige falsamente al caso de tres pedidos. | **PENDIENTE de verificación global** |
| PDF RF-06, consigna p.2 | EHAPP-19/US-008 sin sprint actual; S6 solo en roadmap histórico LEG-V1.2/US-013. Pantalla informativa. No es C1/C2 ni otra historia comprometida en S3. | **PENDIENTE del producto, fuera de compromiso S3 observado** |
| Android emulado | APK normal debug y continuación nativa anteriores, huella idéntica y firma v2 válida verificada hoy. | **APROBADO en emulador/debug** |
| Teléfono físico solicitado | ADB sin dispositivos autorizados conectados. | **BLOQUEADO**, no criterio explícito de US-005 |
| Release solicitada | Firma release usa debug, sin keystore/configuración de entrega ni endpoint HTTPS de distribución validado. | **BLOQUEADO**, no se genera artefacto engañoso |
| Aceptación docente/PO | No hay acta o decisión real aportada; Jira sigue Tareas por hacer/future. | **PENDIENTE** |

Conclusión: demostración técnica de US-005 disponible para revisión; **cierre académico total no acreditado**. No se presentan SP como aceptados ni resultados pendientes como aprobados.
