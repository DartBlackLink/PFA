# Dictamen técnico y académico — Sprint 3

**EcoLogística Huancayo — 04/11/2026, America/Lima. Responsable: Jordy Steve Chancasanampa Torres.**

**Dictamen: PARCIAL para cierre académico completo. Apto para presentar y revisar el incremento funcional US-005; no se declara aceptado ni cerrado el sprint.** Los dos criterios de US-005 tienen evidencia técnica favorable. Falta completar/validar la inspección académica de accesibilidad y seguridad, además de la aceptación real del responsable/docente. Teléfono físico y release están bloqueados por recursos/configuración ausentes; no aparecen como criterios de US-005 en Jira.

## 1. Alcance que se contrastó

Lectura autenticada de Jira, sin escrituras, el 04/11: **EHAPP Sprint 3, id 37**, objetivo primera optimización válida. Única historia observada: **EHAPP-13 / US-005 — Generar rutas optimizadas**, 13 SP, estado **Tareas por hacer**. Sprint **future**, fechas de Jira `2026-10-07T05:00:00Z` a `2026-10-21T05:00:00Z` (07–21/10, 00:00 Perú). No se alteraron calendario, estados, SP ni aceptación.

Jira describe dos criterios: producir una planificación válida con recursos elegibles y rechazar escenarios sin solución factible. La matriz adjunta los separa de la ampliación de operación/incidencias y de los requisitos generales del proyecto. La consigna original menciona Lima; la instrucción vigente del responsable establece **Huancayo y alrededores**. No se cambiaron las referencias históricas ni se trasladaron coordenadas de Lima al sistema.

## 2. APROBADO — verificación técnica delimitada

El 04/11 se completó **enteramente desde la web principal** un nuevo caso QA, con tres pedidos identificados y recursos QA existentes. ADMIN generó una propuesta genética, revisó el mapa y confirmó la asignación. REPARTIDOR inició sesión en otro origen local, confirmó recepción, inició el recorrido y guardó una entrega. Reportó congestión simulada de tres minutos con el punto público del Parque de la Identidad Huanca confirmado manualmente; no se presentó como GPS físico ni tráfico observado.

ADMIN recibió el aviso, abrió la incidencia, comparó la geometría y aprobó el recálculo exclusivo de las dos pendientes. REPARTIDOR vio **versión 2 / recibida 1**, confirmó efectivamente la recepción y terminó las tres entregas. Ruta `f95beaed-6a52-4905-8cd8-c468ce19ddae`: **FINALIZADA, versión 2, recibida 2, tres pedidos únicos**.

La primera entrega conserva `2026-11-04T13:00:16.536244+00:00` (08:00 Perú). Después de reiniciar únicamente FastAPI se compararon ruta, incidencia e historial completos: idénticos. El cliente Web se recargó y volvió a mostrar la ruta finalizada 2/2. Los dos casos QA anteriores permanecen intactos. Los pedidos antiguos sin ubicación o con ventanas vencidas se conservaron; no se adulteraron para aprobar el caso nuevo.

El recorrido inicial fue 7,469 km. Al comparar **pendientes desde la posición actual**, ambas alternativas dieron **4,04 km / 19,10 min** incluyendo cinco minutos de atención por entrega: diferencia **cero**. No se infiere un ahorro comparando el recorrido completo con el tramo pendiente, ni se afirma óptimo global o puntualidad física.

Comprobaciones nuevas de permisos en API principal: sin sesión **401**, repartidor solicitando flota **403**, ruta de otra identidad **404** y listado limitado a rutas de su propietario. Navegación, modales, mapa y guardado se verificaron en el recorrido descrito, en temas existentes. No se reprodujo un defecto nuevo de producto. Los primeros intentos de interacción automática requirieron esperar la carga de Flutter y desplazar fuera del mapa; no se confundieron con pérdida de datos. Esto no certifica que toda la aplicación carezca de errores.

## 3. Pruebas conservadas sin ejecución redundante

No cambió el código probado: **288 destinos de fuentes compartidas D/PFA coinciden**. Se validaron nuevamente los archivos de evidencia y las huellas, sin volver a ejecutar la regresión completa estable.

| Evidencia anterior vigente | Resultado verificado |
|---|---|
| JUnit backend, ejecución 03/11 23:24 Perú | **127 pruebas**, cero fallos/errores/omitidas, aproximadamente 82,74 s; una advertencia de obsolescencia de TestClient. |
| Flutter | **81 aprobadas**, analizador final sin incidencias. Pruebas de 360/768/1440, claro/oscuro y texto ampliado conservadas; no se afirma una nueva ejecución hoy. |
| Coverage.py backend | **2261/2410 líneas**, **478/604 ramas**. Combinada **90,87591240875912408759124088 %**, redondeada **90,88 %**. No es cobertura de Flutter/Android ni una nota global. |
| Android API 36, corte anterior | Continuación nativa aprobada: acuse v2, entregas únicas, desconexión, recuperación sin perder sesión y logout. Los fallos de intentos monolíticos anteriores permanecen documentados. |
| Bandit / pip-audit, corte anterior | Sin hallazgos en el código/requisitos Python examinados. No se repitieron ni se presentan como pentest completo o garantía absoluta. |

HTML de cobertura vigente (archivo local de auditoría: `index.html`) · [XML](../20261103-estabilizacion/coverage.xml) · [JUnit](../20261103-estabilizacion/test-results.xml) · [Detalle previo](../20261103-estabilizacion/RESULTADOS.md).

### SonarQube actual: APROBADO

Análisis SUCCESS en **ecologisticas2.1**, Quality Gate OK/PASSED, cobertura backend **90,9 %**, cero vulnerabilidades/bugs/code smells/hotspots y duplicación0,0 %. Perfiles Sonar way core; no equivale a una auditoría absoluta de seguridad. Se resolvió el bloqueo de credencial/destino, sin modificar permisos ni gate. [Resultado y alcance exactos](SONARQUBE_ACTUAL.md).

## 4. PARCIAL — obligaciones de inspección y alcance global

- El cronograma docente **TP_2 16, página 2**, asocia Inspección 03/Sprint 03 con **SonarQube, accesibilidad y OWASP**. Hay pruebas UI, controles de API y análisis Python, pero no una evaluación manual integral de WCAG/lector de pantalla/teclado ni una revisión OWASP completa de esta entrega. No se inventan conformidades, evaluadores, encuestas ni certificaciones.
- El caso global exige RNF-01 de 150 pedidos/15 vehículos en ≤45 s. Los benchmarks existentes del motor con matriz controlada no prueban el flujo integrado con red y PostgreSQL a esa escala. Tampoco el caso de tres pedidos lo acredita.
- La planificación local V1.2 conserva el esquema anterior de 22 SP/otras fechas e identificadores. La reconciliación del 30/10 ya lo identifica como histórico. La adenda actual confirma Jira como referencia de S3; no se mezclan los dos compromisos ni se cuentan sus SP juntos. Conviene señalar claramente la vigencia en la revisión docente.
- La consigna integral pide indicadores/reportes y funciones ambientales más amplias; la demostración US-005 no equivale a cumplir todos los RF/RNF del producto. El tráfico actual es manual/estimado, no una integración de tráfico vivo.

## 5. BLOQUEADO — verificaciones solicitadas sin requisitos disponibles

| Verificación | Observación concreta | Requisito para desbloquear |
|---|---|---|
| Teléfono físico | `adb devices -l` vacío en dos consultas. No hubo dispositivo autorizado sobre el que ejecutar el caso. | Conectar/autorizar un teléfono y configurar un servidor accesible; repetir permisos GPS, sesión, rutas y recuperación en ese dispositivo. |
| APK release validada | No hay `android/key.properties` ni keystore de entrega en los proyectos comprobados; `build.gradle.kts` configura release con **signingConfigs.debug**. Solo está validada la API HTTP local del emulador. | Firma de entrega protegida, identidad/configuración de distribución y API HTTPS accesible. No generar una release firmada con debug y presentarla como entrega validada. |

## 6. APK realmente validada

**Debug normal**, destino `lib/main.dart`, sin instrumentación QA: `D:\UC\App\ecologistica\build\apk\ecologistica-huancayo-debug.apk`.

- Compilación, instalación y apertura en emulador verificadas en el corte anterior; hoy se confirmó la misma huella.
- SHA-256: `7abd7e926d5939c89c3493cbcfdb750b988dfd38f1f4b1b8a428720a1d474edf`.
- Firma comprobada hoy con Android SDK apksigner: **exit 0, esquema v2 válido, certificado Android Debug**. No contiene una firma de distribución release.
- API configurada: `http://10.0.2.2:8000/api/v1`. Esa dirección es del anfitrión en emulador; no sirve como servidor para un teléfono físico.

## 7. PDF y PENDIENTE académico

**El PDF no está comprometido en el Sprint 3 actual.** Jira lo identifica como **EHAPP-19 / US-008**, cinco SP, Tareas por hacer y **sin sprint asignado**. El antiguo roadmap local lo llamaba **LEG-V1.2/US-013** y lo situaba en **S6**. No se interpreta ese S6 histórico como asignación actual de Jira. La consigna general sí lo exige en RF-06, página 2; sigue siendo una obligación del producto, y la pantalla Reportes continúa informativa. No se implementa ni se da por aceptado aquí.

SonarQube de la misma versión ya está acreditado. Para cerrar formalmente S3: completar y registrar el alcance de inspección WCAG/OWASP requerido por el docente y obtener revisión/aceptación real. Jordy debe contrastar el estado/futuras fechas de Jira y aprobar sus cambios antes de aplicarlos. No se efectuaron transiciones ni publicaciones.

## 8. Evidencia y preservación

[Matriz criterio por criterio](MATRIZ_ACEPTACION.md) · [Alcance y reconciliación](ALCANCE_Y_RECONCILIACION.md) · [Caso y recursos QA](web-case.json) · [Primera entrega](first-delivery.json) · [Estado antes](before-restart.json) · [Estado después](after-restart.json) · [Resultado de persistencia](persistence-result.json) · [Permisos](permission-checks.json) · Auditoría de sincronización/secretos (archivo local de auditoría: `sync-secret-audit.json`) · [Firma APK](apk-signature.txt).

El escaneo de texto Git visible no encontró los secretos conocidos, tokens Sonar ni claves privadas buscadas, ni candidatos de archivos privados. No cubre exhaustivamente historia Git, imágenes ni todas las clases de secreto. No se publicaron configuraciones privadas, contraseñas, archivos de firma, Compose o APK de instrumentación. Sprints 1/2 y evidencias previas se conservaron. No se modificaron fuentes funcionales ni se reejecutaron scripts antiguos de aplicación.
