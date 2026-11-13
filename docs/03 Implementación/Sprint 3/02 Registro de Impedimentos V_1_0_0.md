**Dictamen vigente 04/11/2026: PARCIAL para cierre académico; US-005 técnicamente demostrado.** [Cierre y evidencia](../evidencias/20261104-cierre/INFORME_CIERRE_SPRINT3.md). Los cortes anteriores se conservan como historial.

**Último corte verificado: 03/11/2026, estabilización principal y Android.** [Resultado vigente](../evidencias/20261103-estabilizacion/RESULTADOS.md). Los apartados fechados anteriores se conservan como historial.

> Corte operativo vigente: Huancayo, Junín, Perú; America/Lima es la zona horaria válida. Los apartados de cortes anteriores se conservan como historial.

[Índice de implementación](../README.md) · [README del proyecto](../../../README.md)

# Registro de impedimentos — Sprint 3

**Proyecto:** EcoLogística Huancayo, adaptación de la consigna académica original de Lima. **Responsable:** Jordy Steve Chancasanampa Torres. **Sprint:** 3. **Versión:** 1.0.0. **Corte técnico:** 30/10/2026.

## Criterio de registro

Se registra un impedimento cuando una condición detiene una actividad comprometida y requiere gestión para continuar; no se convierte cada validación, riesgo o error corregible en un impedimento.

En el corte del 30/10 no se aportó evidencia de una interrupción del sprint con fecha, impacto y responsable que permita completar una fila histórica. La tabla se conserva vacía de forma intencional: no equivale a afirmar que nunca hubo impedimentos.

| Impedimento # | Fecha de registro | Descripción e impacto | Prioridad | Reportado por / responsable | Fecha tope de resolución | Estado | Fecha de resolución | Resolución y evidencia |
|---|---|---|---|---|---|---|---|---|

## Gestión del registro

Jordy incorporará una fila si se acredita una detención real: actividad afectada, duración, gestión necesaria y enlace a su evidencia. Los riesgos del proveedor están en el informe de estado; los errores de código se gestionan con sus pruebas; la confirmación de Jira y las capturas se gestionan en [Acciones externas](../evidencias/20261030/ACCIONES_EXTERNAS.md).

## Registro de la sesión correctiva — 02/11/2026

| Impedimento # | Fecha | Impacto real | Responsable de atención | Estado / resolución |
|---|---|---|---|---|
| IMP-S3-C01 | 02/11/2026 | Motor Docker detenido: no se podía iniciar el diagnóstico integrado Web/API/PostgreSQL. | Sesión de mantenimiento técnico solicitada por Jordy | Resuelto el mismo día: arranque con docker desktop start, PostgreSQL healthy y /health HTTP 200. Esta intervención no ejecutó borrado de volúmenes ni reset de fábrica. |

Se distingue este bloqueo observado de los defectos gestionables del producto, registrados en Defectos y correcciones (archivo histórico local del corte de Lima). SonarQube fue diferido expresamente; no se registra como un fallo técnico ni se inventa una credencial.

## Ampliación de tráfico e incidencias — verificación nocturna del 02/11/2026

Al comenzar esta ampliación, Docker/PostgreSQL de QA no estaban disponibles y se detuvo la preparación de la suite. Se recuperó el entorno de QA y la regresión final se ejecutó sobre la base desechable protegida. No se borró ni reinició la base principal.

Este hecho actualiza la evidencia de recuperación del entorno; no se inventa un impedimento histórico ni una reunión del Sprint 3. La restricción obsoleta de QA, los errores de montaje de tests y el refresco del formulario se gestionaron como defectos del proceso/código, no como nuevos impedimentos Scrum. Problemas y solución observada (archivo histórico local del corte de Lima) · Dependencias y acciones (archivo histórico local del corte de Lima).

## Corrección territorial y verificación — 03/11/2026

El entorno QA quedó detenido tras la interrupción; se recuperaron sus contenedores existentes conservando la base. No constituye impedimento abierto al finalizar esta recuperación. El pedido sin coordenadas se gestiona como calidad de datos y no se presenta como impedimento externo. Para acciones restantes: [lista separada](../evidencias/20261103-huancayo/PENDIENTES.md).

## Disponibilidad para verificación — 03/11/2026

Docker y el emulador estaban detenidos al recuperar la sesión y bloquearon temporalmente la continuación. Se recuperaron los servicios y se utilizó un AVD QA oficial API 36 separado, conservando el emulador anterior. El flujo principal ADMIN/Android y la persistencia se verificaron; este bloqueo de entorno quedó resuelto.

No se añaden aquí como impedimentos Scrum los defectos corregidos del mapa, los errores del test, la jornada agotada del caso anterior ni los datos incompletos: son incidencias gestionables del proyecto. La falta de token impide únicamente un nuevo análisis SonarQube y se registra como dependencia de verificación, sin inventar una aprobación. [Acciones y responsables](../evidencias/20261103-estabilizacion/PENDIENTES.md).

## Impedimento observado para la inspección — 04/11/2026

| ID | Fecha | Detención e impacto | Prioridad | Responsable/acción | Estado |
|---|---|---|---|---|---|
| IMP-S3-C01 | 04/11/2026 | El nuevo análisis SonarQube de esta versión no puede ejecutarse: servidor UP, archivo local de token ausente y variable SONAR_TOKEN ausente. Impide acreditar este componente de la Inspección03; no afecta al recorrido Web ya comprobado. | Alta | Jordy: proporcionar una credencial vigente mediante almacenamiento local seguro; ejecutar análisis y conservar analysisId/Quality Gate. No usar tokens expuestos. | Resuelto: análisis SUCCESS/gate OK, 04/11/2026 |

La consulta de teléfono y release se registra en el informe como bloqueo de verificaciones adicionales, sin adjudicarlas retroactivamente como historias comprometidas. Las discrepancias de baseline y los datos antiguos se gestionan como documentación/calidad de datos; no se registran como impedimentos ficticios. [Estados y desbloqueo exacto](../evidencias/20261104-cierre/INFORME_CIERRE_SPRINT3.md).

## Resultado SonarQube — 04/11/2026, 08:35 Perú

Proyecto **ecologisticas2.1** confirmado por Jordy. Procesamiento SUCCESS y **Quality Gate OK/PASSED**; cobertura backend **90,9 %**, cero vulnerabilidades/bugs/code smells/hotspots, duplicación0,0 %, perfiles Sonar way core. El bloqueo de análisis quedó resuelto; no se atribuye esta cifra a Flutter ni se declara cierre académico total. Los intentos sobre la clave antigua no alteraron permisos o gate. [Resultado, analysisId y límites](../evidencias/20261104-cierre/SONARQUBE_ACTUAL.md).

## Situación de impedimentos tras consolidar — 04/11/2026

No se registran duplicación de servidores ni datos de demostración como nuevos impedimentos externos: se gestionaron técnicamente dentro del proyecto. Continúan los bloqueos de comprobación en teléfono físico (ADB no detecta dispositivos) y distribución release (firma/configuración de entrega no disponibles), conforme al corte de cierre. No hay credencial nueva guardada localmente para repetir Sonar; el análisis exitoso de ecologisticas2.1 del mismo día conserva su validez y alcance. La aceptación académica pendiente no se convierte en aprobación por consolidar Docker. [Resultados, pruebas y cobertura HTML/XML](../evidencias/20261104-consolidacion/RESULTADOS.md).
