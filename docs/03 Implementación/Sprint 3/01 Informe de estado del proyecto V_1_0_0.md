**Dictamen vigente 04/11/2026: PARCIAL para cierre académico; US-005 técnicamente demostrado.** [Cierre y evidencia](../evidencias/20261104-cierre/INFORME_CIERRE_SPRINT3.md). Los cortes anteriores se conservan como historial.

**Último corte verificado: 03/11/2026, estabilización principal y Android.** [Resultado vigente](../evidencias/20261103-estabilizacion/RESULTADOS.md). Los apartados fechados anteriores se conservan como historial.

> Corte operativo vigente: Huancayo, Junín, Perú; America/Lima es la zona horaria válida. Los apartados de cortes anteriores se conservan como historial.

[Índice de implementación](../README.md) · [README del proyecto](../../../README.md)

# Informe de estado — Sprint 3

**Proyecto:** EcoLogística Huancayo, adaptación de la consigna académica original de Lima. **Responsable:** Jordy Steve Chancasanampa Torres. **Sprint:** 3. **Versión:** 1.0.0. **Corte técnico:** 30/10/2026.

**Periodo del informe:** 30/10/2026–30/10/2026, fecha de implementación y verificación de este incremento. No sustituye las fechas oficiales de inicio/cierre del sprint.

## Estado del proyecto

| Variable de control | Resultado exclusivo del incremento |
|---|---|
| Alcance | RF-03: generación de rutas mediante algoritmo genético, vista previa, confirmación y consulta. Referencia comunicada por el responsable: EHAPP-13 / US-005, Sprint 3, 13 SP. La lectura autenticada de Jira no pudo verificarse; no se declara aceptación ni se suman esos SP como terminados. |
| Cronograma | Incremento técnico ejecutado el 30/10. Las fechas del sprint y su compromiso deben contrastarse con Jira antes del cierre; no se usa la antigua propuesta de 22 SP. |
| Costos | No se aportó un registro de horas o desembolsos exclusivo de S3. No se transforma el presupuesto global en gasto real. |
| Calidad | 94 pruebas backend aprobadas, cobertura combinada de líneas/ramas 91,39 %; 58 pruebas Flutter aprobadas; analizador Dart sin incidencias; Web release compilada. Ruff, Bandit y pip-audit sin hallazgos en esta ejecución. SonarQube ecologisticas: gate OK, cobertura 91,4 % y cero incidencias abiertas con perfiles Sonar way core. Estas herramientas no prueban ausencia absoluta de vulnerabilidades. |

## Cambios y mejoras

| Componente | Implementación y finalidad |
|---|---|
| Motor | Población de permutaciones, selección por torneo, cruce ordenado, mutación e elitismo. Busca una solución factible; no certifica un óptimo global. |
| Restricciones | Peso, atención completa dentro de cada ventana, turno, jornada disponible, pausas y cruces de repartidor/vehículo. Los pares de repartidor y vehículo los selecciona el administrador; el motor distribuye y ordena los pedidos entre esos equipos. |
| Datos viales | Matrices dirigidas OSRM, lotes acotados, caché temporal y validación de cada tramo final; no se reemplaza un fallo por líneas rectas presentadas como rutas viales. |
| Confirmación | Vista previa de 10 minutos sin asignación; confirmación transaccional, idempotente y con comprobación de cambios. Se guardan semilla, parámetros, secuencia, ETA, geometría y estimaciones. |
| Integración | La Web permite elegir pedidos/equipos, revisar y confirmar. Las rutas confirmadas se consultan por administrador y por su repartidor con los permisos existentes. |
| Migración | 0005 añade plan_optimizacion y el vínculo opcional con ruta. El arranque local conservó 8 vehículos, 8 repartidores, 23 pedidos y 21 rutas. |
| Calidad transversal | Consulta de rutas por lotes y retiro del .env como recurso Web. No se adjudican EN-002, EN-003 o EN-005 como historias aceptadas sin compromiso verificable. |

## Riesgos

| Riesgo | Responsable | Mitigación |
|---|---|---|
| Indisponibilidad o demora del proveedor vial de demostración | Jordy | Plazos acotados, respuesta controlada y ausencia de asignaciones parciales; usar proveedor con capacidad contratada antes de producción. |
| Confundir estimaciones de combustible/CO₂ con mediciones reales | Jordy | Identificar fórmula, factores del vehículo y ausencia de tráfico/telemetría real. |
| Confundir el resultado técnico con cierre Scrum | Jordy | Contrastar compromiso, fechas y decisión real de revisión en la lista de acciones separada. |

## Próximos avances

Realizar la demostración con ventanas compatibles, registrar la revisión real y repetir las verificaciones si se modifica el código. El análisis SonarQube de este incremento ya se ejecutó: [resultado y alcance](../evidencias/20261030/SONARQUBE.md). La APK no forma parte de la evidencia técnica de este incremento Web.

## Notas

[Pruebas y límites de la verificación](../evidencias/20261030/RESULTADOS.md). [Acciones externas y cierre](../evidencias/20261030/ACCIONES_EXTERNAS.md). El objetivo de 150 pedidos/15 equipos se probó en el motor con datos sintéticos; no acredita todavía el límite de 45 s para el flujo completo con red y base de datos.

## Actualización técnica — 02/11/2026

Corrección funcional posterior al corte histórico: avisos visibles, diagnóstico de recursos con rutas sin horario, validación de ventanas, mapa previo y cancelación persistente. Flujo ADMIN → planificación genética → confirmación → REPARTIDOR → operación → consulta administrativa comprobado con datos QA independientes y persistencia tras reiniciar API. Entregas/incidencias corresponden a integración adicional solicitada de US-010/S5; no cambia el compromiso reportado de US-005 ni su estimación.

Nueva versión: 99 pruebas backend, 64 Flutter, 91.47% de cobertura combinada backend. Análisis Flutter sin incidencias, Bandit 0 y dependencias fijadas sin vulnerabilidades conocidas al corte. SonarQube de esta versión fue diferido por el usuario. APK de depuración compilada; ejecución funcional nativa todavía sin resultado aprobado. Consultar ANDROID.md y el registro de ejecución.

Resultados y alcance (archivo histórico local del corte de Lima) · Pendientes (archivo histórico local del corte de Lima).

## Ampliación de tráfico e incidencias — verificación nocturna del 02/11/2026

La ampliación solicitada agrega estimación manual por zona y horario, reportes de tráfico, avisos persistentes, propuesta de reoptimización, aprobación transaccional, versiones y acuse del repartidor. Se conserva el compromiso formal consultado: Jira asigna US-005/EHAPP-13 al Sprint 3; US-006, US-009, US-010 y EN-002 no tienen sprint en la respuesta. La ampliación no equivale a aceptación Scrum ni cambia estados.

Verificación más reciente: **109 pruebas backend, 71 Flutter; cobertura combinada backend 90,88 % (2198/2342 líneas y 463/586 ramas)**. Es una medición nueva de Coverage.py; SonarQube no se ejecutó. El GOLD de QA conservó la primera entrega, aprobó versión 2, recibió acuse efectivo y finalizó tres pedidos distintos; se comprobó persistencia tras reiniciar API. No se inventó ahorro: la comparación de secuencias pendientes dio diferencia cero.

La web principal 8080 continúa sin despliegue nuevo por decisión previa. Resultados actuales (archivo histórico local del corte de Lima) · Cobertura navegable (archivo local de auditoría: `index.html`) · Rendimiento y alcance (archivo histórico local del corte de Lima) · Android (archivo histórico local del corte de Lima) · Acciones necesarias (archivo histórico local del corte de Lima).

## Corrección territorial y verificación — 03/11/2026

Estado técnico actual: generación/confirmación genética con red vial de Huancayo; incidencia, propuesta, aprobación y acuse v2 comprobados en QA. 127 backend y73 Flutter recuperadas; cobertura combinada90,88 %. Sonar histórico separado. No equivale a cierre Scrum. Datos y resultados actuales: [evidencia](../evidencias/20261103-huancayo/RESULTADOS.md).

## Estabilización principal y Android — 03/11/2026

La web principal 8080/API8000 quedó desplegada con la corrección del mapa y el panel del repartidor; ya no corresponde al estado anterior de despliegue diferido. ADMIN generó y confirmó tres destinos de Huancayo. Android inició, guardó una entrega y reportó congestión QA; ADMIN abrió el aviso, comparó y aprobó la versión 2 para dos pendientes; Android acusó recepción y finalizó tres pedidos únicos. El estado completo persistió tras reiniciar API.

Calidad de este corte: **127 backend aprobadas**, **81 Flutter aprobadas**, analizador sin incidencias y un caso nativo compuesto de continuación aprobado. Cobertura combinada backend **90,87591240875912408759124088 %** (2261/2410 líneas y 478/604 ramas). Bandit/pip-audit sin hallazgos en sus alcances. SonarQube restaurado, sin análisis nuevo por ausencia de token local; no reutilizar el 91,4 % histórico.

APK normal debug compilada, instalada y abierta en emulador API 36; no se atribuye a teléfono físico ni distribución release. No se modifica el compromiso formal de Jira ni se declara cierre Scrum. [Informe y evidencia](../evidencias/20261103-estabilizacion/RESULTADOS.md) · Cobertura HTML (archivo local de auditoría: `index.html`).

## Dictamen técnico y académico — 04/11/2026

Periodo de esta comprobación: 04/11/2026; corresponde exclusivamente al incremento del Sprint 3 y no modifica el calendario oficial. Jira leído hoy confirma una historia, EHAPP-13/US-005, 13 SP, dos criterios: solución válida y rechazo de inviabilidad. Continúa Tareas por hacer en Sprint 37/future. No se cuentan SP como aceptados ni se inventa una revisión del profesor.

Nuevo flujo completo en Web principal ADMIN/REPARTIDOR: generación, mapa, asignación, primera entrega, incidencia manual, comparación/replan de dos pendientes, aprobación, recepción efectiva v2 y tres entregas únicas. Reinicio API y recarga Web conservaron historial; dos casos anteriores intactos. Los 127 backend/81 Flutter y la cobertura backend 90,88 % permanecen vigentes por igualdad de fuentes, sin repetir suites. Se compararon 288 destinos y la APK conserva SHA/firma debug válidos.

Dictamen de cierre: **PARCIAL**. US-005 es técnicamente demostrable; SonarQube nuevo ya aprobó en ecologisticas2.1; la inspección manual WCAG/OWASP debe completarse/validarse. Teléfono físico y release carecen de requisitos disponibles. PDF está en EHAPP-19 sin sprint asignado, fuera de US-005. [Informe final y estados](../evidencias/20261104-cierre/INFORME_CIERRE_SPRINT3.md) · [Matriz criterio por criterio](../evidencias/20261104-cierre/MATRIZ_ACEPTACION.md).

## Resultado SonarQube — 04/11/2026, 08:35 Perú

Proyecto **ecologisticas2.1** confirmado por Jordy. Procesamiento SUCCESS y **Quality Gate OK/PASSED**; cobertura backend **90,9 %**, cero vulnerabilidades/bugs/code smells/hotspots, duplicación0,0 %, perfiles Sonar way core. El bloqueo de análisis quedó resuelto; no se atribuye esta cifra a Flutter ni se declara cierre académico total. Los intentos sobre la clave antigua no alteraron permisos o gate. [Resultado, analysisId y límites](../evidencias/20261104-cierre/SONARQUBE_ACTUAL.md).

## Consolidación operativa — 04/11/2026

Este corte mantiene el alcance del Sprint 3; no cambia fechas ni aceptación de Jira. Compose ecologistica reúne postgres/api/web construidos desde la fuente principal, sin montajes de stage. El responsable confirmó que todos los registros anteriores eran pruebas: se conserva su base completa y se abre ecologistica_operativa sin datos de negocio ficticios, con un ADMIN inicial privado. Login Web y API vacía comprobados. El respaldo principal y las bases QA fueron restaurados y comparados por tabla.

Se repitió la regresión por el cambio de entorno/imagen: **127 backend y 81 Flutter aprobadas**, analizador sin incidencias; cobertura backend **90,88 %** (2261/2410 líneas y 478/604 ramas). No se repitió el flujo Android ni todo el recorrido ADMIN/REPARTIDOR contra la base vacía; sus evidencias anteriores conservan fecha y alcance. No hay teléfono conectado ni token nuevo local disponible para otro análisis Sonar. Se mantiene el dictamen académico PARCIAL. [Resultados, pruebas y cobertura HTML/XML](../evidencias/20261104-consolidacion/RESULTADOS.md).
