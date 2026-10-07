[README principal](README.md)

# Guía de ajustes y cierre de EcoLogística

**Responsable:** Jordy Steve Chancasanampa Torres. **Fecha:** 07/10/2026. **Versión:** 1.0.0.

Los documentos definen una línea base de diseño y ejecución. Este archivo reúne lo que debes configurar en Jira, actualizar en Figma/imágenes, implementar y demostrar para que la entrega coincida con esa línea base. El calendario 12/10/2026-18/01/2027 es una propuesta futura; no declara que los sprints se ejecutaron. El software, Jira y los PNG no se modificaron durante esta corrección documental.

## 1. Jira: proyecto, campos y calendario

1. Consolidar **EcoLogística Huancayo / EHAPP** como proyecto del trabajo. Conservar claves EHAPP, historial y capturas anteriores; no mezclar Done o releases SCRUM con EHAPP.
2. Usar US-001..014, EN-001..009 y EP-01..07 en título/descripción. Cada Story/Task debe tener objetivo, al menos dos BDD, prioridad, SP, RF/RNF, componente, responsable Jordy, sprint, dependencias y **Fix Version v1.0.0-MVP**. Bug enlazado a historia; subtask no vuelve a sumar SP del padre.
3. Configurar flujo **To Do → In Progress → In Review/QA → Done**, con retorno a ejecución ante defectos. Planificar en To Do; conservar estados reales del trabajo existente. Done solo con evidencia y DoD, sin alterar fechas pasadas para aparentar ejecución.
4. Crear/actualizar los siete sprints con hora 09:00 America/Lima y fechas propuestas siguientes. Si debes conservar un calendario académico distinto, desplazar todos los periodos y sus hitos de manera coherente, sin cambiar el historial real.

| Sprint | Inicio | Fin (frontera exclusiva) | Goal | SP |
| --- | --- | --- | --- | --- |
| S1 | 12/10/2026 | 26/10/2026 | Base técnica y acceso por rol con RN-023 | 22 |
| S2 | 26/10/2026 | 09/11/2026 | Flota/repartidores, UX y contrato | 19 |
| S3 | 09/11/2026 | 23/11/2026 | Pedidos/clientes/preferencias | 19 |
| S4 | 23/11/2026 | 07/12/2026 | Algoritmo genético y benchmark | 21 |
| S5 | 07/12/2026 | 21/12/2026 | Mapa y operación móvil | 24 |
| S6 | 21/12/2026 | 04/01/2027 | Reoptimización, KPIs y PDF | 24 |
| S7 | 04/01/2027 | 18/01/2027 | Compensación, calidad y release | 20 |

### Alcance a colocar en Sprint 1 y Sprint 2

| Sprint | Actividades ejecutables y SP | Configuración específica |
| --- | --- | --- |
| S1 | US-001 3; US-002 3; EN-001-S1 3; EN-002-S1 5; EN-007-S1 5; EN-003-S1 3 = **22 SP** | RN-023 en ambas historias y enabler de seguridad. Componentes web/mobile/backend-api/database/security/figma/qa según tarea. Goal incluye login y bloqueo progresivo |
| S2 | US-003 5; US-004 5; EN-005-S2 3; EN-007-S2 3; EN-009-S2 3 = **19 SP** | Flota/repartidores, campos válidos, teclado/contraste y documentación. Componentes web/backend-api/database/figma/qa/documentation según tarea |

Las porciones técnicas tienen SP propios; los EN agregados son catálogo, no trabajo adicional a sumar. Mantener US-001/US-002 en 3 SP de referencia y la política compartida en EN-003-S1; revisar viabilidad en Planning según capacidad, sin estimar velocidad con estos valores.

### Equivalencias de actividades actuales

| Issue visible | Texto/código de captura | Equivalencia documental | Acción pendiente |
| --- | --- | --- | --- |
| EHAPP-8 | EN-001 Base técnica | EN-001 | Revisar alcance y porciones |
| EHAPP-9 | US-001 Acceso básico | US-001 y parte de US-002 | Separar aceptación Web/móvil |
| EHAPP-10 | US-002 Flota | US-003 | Actualizar referencia documental en Jira |
| EHAPP-11 | US-003 Conductores | US-004 | Unificar campos y estimación |
| EHAPP-12 | US-004 Pedidos | US-005 | Completar campos y BDD |
| EHAPP-13 | US-005 Rutas | US-007 | Precisar algoritmo genético |
| EHAPP-14 | EN-002 Rendimiento | EN-004 | No confundir con EN-002 documental de BD |
| EHAPP-15 | US-006 Mapa | US-008 y parte de US-009 | Separar permisos por rol |
| EHAPP-16 | US-007 Dashboard | US-012 | Unificar referencia |
| EHAPP-17 | EN-003 Seguridad | EN-003 | Validar criterios y porciones |
| EHAPP-18 | EN-004 Accesibilidad | EN-005 y parte de EN-007 | Unificar alcance |
| EHAPP-19 | US-008 PDF | US-013 | Vincular prueba de descarga |
| EHAPP-20 | US-010 Incidencia | US-010 | Validar entrega además de incidente |
| EHAPP-21 | US-009 Reoptimización | US-011 | Unificar referencia |
| EHAPP-22 | EN-005 Pruebas/documentación | EN-009 y QA transversal | Separar evidencias de prueba |
| EHAPP-23 | US-11 Preferencias | US-006 | Incluir canal directo cliente |
| EHAPP-24 | US-12 Compensación | US-014 | Unificar referencia |
| SCRUM-10 / SCRUM-11 | Base técnica / Acceso | Histórico: no asumir equivalencia de estado EHAPP | Conservar evidencia sin mezclar cierres |

EHAPP-9 requiere separar acceso ADMIN y REPARTIDOR; conservar el vínculo y crear una actividad ejecutable para el segundo canal si corresponde. Completar EN-002-S1 (BD), porciones UX/seguridad y accesibilidad/documentación S2 que no estén representadas. No renumerar claves Jira manualmente: los IDs documentales son referencias en texto. Usar el backlog completo de Transformando a ágil para historias, BDD y dependencias.

## 2. Login: cambio de software y validación

**RN-023:** Tras el tercer fallo consecutivo: 5 s; siguiente fallo después de la espera: 10 s; siguiente fallo: 300 s (5 min). Fallos posteriores mantienen 300 s hasta un acceso correcto o recuperación validada. El éxito reinicia contador y plazo; la espera sola no reinicia la secuencia. Peticiones durante bloqueo no suman fallos ni amplían el plazo.

| Capa | Qué implementar | Qué comprobar |
| --- | --- | --- |
| API | Validación de credenciales; contador/plazo por identificador; transición atómica; respuesta 429/Retry-After | Fallos 3/4/5 producen 5/10/300 s, también para identificadores inexistentes con respuesta genérica |
| PostgreSQL | Migración control_acceso con identificador HMAC, intentos 0..5 y bloqueo_hasta | Estado compartido entre dispositivos/réplicas; no borrarlo al recargar/reiniciar |
| Flutter Web/móvil | Botón deshabilitado, mensaje accesible, contador con reloj/plazo del servidor | 5 y 10 segundos visibles; 5:00 para 300 s; reactivar solo tras vencimiento |
| Sesión | Validar vigencia/rol al restaurar; logout limpia credenciales locales | Credenciales correctas durante espera aún bloqueadas; tras vencer éxito reinicia intentos |
| QA | S1-C04..08 y regresión S2-C06 | Recarga, dos dispositivos, concurrencia, errores de red y límites antes/después del plazo |

**Actualización técnica 07/10/2026:** RN-023 ya está implementada en API/PostgreSQL/Flutter. Pasaron siete casos de integración de API y siete de Flutter, incluyendo bloqueos, concurrencia, sesión y contador. Los vencimientos largos se simularon únicamente en la base temporal de pruebas; falta evidencia de la espera completa en dispositivos reales. Esto no equivale al cierre del Sprint. No capturar contraseñas, token JWT, secretos ni datos reales innecesarios.

## 3. Otras correcciones del prototipo

| Prioridad/hito | Cambio necesario | Criterio de cierre |
| --- | --- | --- |
| S1 / IMP-02 | Integrar fuentes externas y separar clientes Web/móvil/API; excluir builds/entornos/secretos | Arranque limpio independiente y configuración de ejemplo |
| S1 / IMP-03 | Reemplazar create_all mutable por migraciones explícitas y controles del diseño | Upgrade con CHECK/FK y datos conservados |
| S1 / IMP-04 | Sesión vencida y listado de rutas por propietario | Casos de rol/identidad y RN-023 aprobados |
| S2 / IMP-05 | Capacidad/consumo >0, placa normalizada única y error controlado | CRUD/inactivación y rechazo de cero/duplicados |
| S2 / IMP-06 | Separar DNI/licencia/categoría/contacto/disponibilidad/origen; no generar DNI para alta real | Lectura posterior preserva todos los campos |
| S2 / IMP-07 | Formularios completos, accesibilidad y contrato/manual reales | Teclado/contraste/errores; documentación sin endpoints inexistentes |
| S3 | Coordenadas, referencia, volumen, ventanas y preferencias CLIENTE | Pedido listo completo y acceso propio/asistido auditado |
| S4-S7 | Motor genético backend, benchmark, ruta móvil/eventos, KPIs/PDF y compensación | RF/RNF y DoD evaluados por historia; no presentar OSRM ni cifras de demo como resultados |

Las fallas del prototipo identificadas en la revisión inicial se corrigieron en acceso, rutas por propietario, migraciones explícitas, flota, campos de repartidor y pruebas. La versión activa es `D:\UC\App\ecologistica`. El mapa con recorridos fijos y los reportes con cifras simuladas fueron retirados; el optimizador y los reportes calculados siguen pendientes. El detalle está en `D:\UC\App\ecologistica\CAMBIOS_Y_PENDIENTES.md`.

**Datos históricos por completar:** existe un perfil anterior con DNI generado, horario colocado en contacto y disponibilidad/origen incompletos. Completar DNI real de ocho dígitos, licencia/categoría, experiencia, teléfono, horario, coordenadas y correo accesible desde el formulario. No inventar esos datos ni usarlo como evidencia de una historia terminada. Las restricciones nuevas preservan los registros anteriores mediante CHECK NOT VALID; después de corregirlos se debe validar la integridad histórica.

## 4. Imágenes Jira que debes actualizar

Guardar en `docs/02 Planificación/evidencias/`, usando capturas reales del proyecto EHAPP. Recortar panel relevante; mostrar fechas/objetivo/actividades legibles y evitar navegador/escritorio innecesarios. No reemplazar una captura histórica por una ilustración generada.

| Archivo de imagen | Contenido final requerido | Corrección del material actual |
| --- | --- | --- |
| evidencia-01-roadmap.png | Roadmap EHAPP con siete sprints y calendario configurado | Actualmente es backlog S1 de 6 SP; volver a capturar la pantalla correcta |
| evidencia-02-backlog.png | IDs canónicos, SP, épicas, componentes y Fix Version | Conciliar códigos y mostrar campos; conservar claves EHAPP |
| evidencia-03-sprint1.png | Planning S1: Goal de acceso/RN-023, fechas, seis elementos y 22 SP | Actualmente es tablero SCRUM; sustituir por Planning EHAPP |
| evidencia-04-tablero.png | Tablero EHAPP con sprint, estados y actividades | Actualmente es cronograma; obtener tablero del mismo proyecto |
| evidencia-05-release.png | v1.0.0-MVP EHAPP con issues asociados y estado real | Actualmente SCRUM sin actividades; asociar Fix Version, no publicar antes de aceptación |
| evidencia-06-sprint2.png (nueva) | Planning S2, Goal, fechas, cinco elementos y 19 SP | Agregar tras configurar S2 |

Capturas de ejecución adicionales por sprint: tablero al cierre, Sprint Report/burndown con historial real y resultado del demo. Guardar en `docs/03 Implementación/evidencias/sprint-1/` y `sprint-2/`; añadir enlaces al Review únicamente después de crear los archivos. No marcar historias Done para obtener una imagen favorable.

## 5. Figma y capturas de interfaz

| Diseño/archivo | Qué modificar o agregar |
| --- | --- |
| figma-05-login-movil-repartidor.png | Email/contraseña; estados error, bloqueo 5 s, 10 s y 05:00; botón deshabilitado y reactivado |
| Login ADMIN Web (nuevo diseño) | Misma política RN-023, ayuda, foco y anuncio accesible del bloqueo; no anunciar cada segundo al lector de pantalla |
| figma-03-gestion-pedidos-flota.png y formularios nuevos | Formulario vehículo completo; duplicados/cero; edición/inactivación; campos conductor separados y ventana/disponibilidad |
| Pedidos/preferencias/PDF (nuevos diseños) | Campos RF-02; área CLIENTE RF-09; salida PDF con periodo/fuentes/parámetros |
| figma-06/07/08 | Ruta propia, entrega/incidente, vacío, error, offline y sincronización |

No borrar los ocho diseños actuales; extender flujos y exportar solo los PNG que cambien. Las capturas de mockup prueban diseño; para validar login obtener capturas de la aplicación ejecutada y resultados de pruebas por cada duración.

## 6. Evidencias y datos que faltan para cerrar la entrega

| Elemento | Qué aportar | Dónde reflejarlo |
| --- | --- | --- |
| Calendario/compromiso | Fechas acordadas y scope configurado; preservar historial si difiere de la propuesta | Artefactos Jira, Informe y Review |
| Pruebas | Caso, versión, entorno, pasos, esperado/obtenido, resultado y evidencia; S1-C01..08 y S2-C01..06 | Review y adjuntos Jira |
| DoD | Cobertura ≥80%, revisión por par, staging automatizado y documentación; registrar decisión docente para adaptación individual | Enablers/Review y registro de cierre |
| Demo/feedback | Fecha, participantes reales, versión mostrada, observaciones y decisiones | Review separado S1/S2 |
| Retrospectiva | Aprendizajes observados, acciones, resultado y seguimiento de arrastres | Retrospectiva S1/S2 |
| Impedimentos | Fecha real de resolución, actividad, corrección y prueba | Registro de Impedimentos |
| Costos/esfuerzo | Horas y compras con comprobante, moneda y fecha | Informe/presupuesto; no afirmar gasto cero sin registro |
| Adaptación académica | Respuesta docente sobre Flutter/modalidad/escenario de evaluación | ADR/supuestos y expediente |
| Normas/datos operativos | Fuentes/vigencia de restricciones, tráfico y factores antes de uso real | Restricciones y parámetros de ejecución |

Hoy solo hay capturas de Jira y revisión estática del prototipo; no hay expediente que permita certificar pruebas, demos, feedback o cierre de sprint. Por eso los documentos se redactan como plan detallado. Al ejecutar, registrar hechos y resultados reales; no llenar ese expediente con eventos inventados.

## 7. Orden recomendado y control final

1. Configurar EHAPP, calendario, IDs, 22/19 SP, RN-023 y Fix Version.
2. Ajustar mockups/login y formularios.
3. Implementar/corregir software S1, luego S2; ejecutar sus casos y DoD.
4. Capturar evidencia real y registrar demo/feedback/retrospectiva por sprint.
5. Actualizar los cuatro archivos con resultados y cerrar impedimentos según prueba; revisar coherencia de Inicio/Planificación.
6. Incorporar fuentes al repositorio único, verificar gitignore/enlaces/secretos y realizar la subida manual a Git cuando decidas.

Comprobar 17 documentos separados de Inicio/Planificación, cuatro de Implementación, README con enlaces relativos y retorno, versiones/historial coherentes, nombres de plantilla y evidencias existentes. La corrección documental conserva los nombres exigidos; no hace commits ni push.

## Anexo: capturas históricas conservadas

### Contenido previo a los ajustes

Los nombres originales de imágenes se preservan para mantener trazabilidad; los títulos siguientes describen el contenido real. Una evidencia histórica insuficiente se conserva y se señala como pendiente de reemplazo por captura real del mismo proyecto.

#### Captura A - Sprint Backlog EHAPP y objetivo visible

![Sprint Backlog EHAPP](docs/02%20Planificaci%C3%B3n/evidencias/evidencia-01-roadmap.png)

Aunque el archivo se llama roadmap, muestra Sprint 1 del 14 al 28 de septiembre, dos actividades de 3 SP y botón Iniciar sprint. Acredita planificación capturada de 6 SP y objetivo visible; no acredita ejecución ni cierre. No corresponde a un Roadmap.

#### Captura B - Backlog EHAPP

![Backlog EHAPP](docs/02%20Planificaci%C3%B3n/evidencias/evidencia-02-backlog.png)

Muestra 17 actividades con épicas, SP y estados. Los códigos US/EN difieren del catálogo documental según la equivalencia anterior. No muestra todos los componentes ni los criterios BDD; esos campos no se dan por comprobados.

#### Captura C - Tablero histórico SCRUM

![Tablero histórico SCRUM](docs/02%20Planificaci%C3%B3n/evidencias/evidencia-03-sprint1.png)

Muestra espacio EcoLogística Lima, SCRUM-10/SCRUM-11, una tarjeta Por hacer, una En curso y cero Finalizado. No es evidencia del Sprint Planning EHAPP ni de historias terminadas. Se requiere tablero del proyecto consolidado con sprint y estados reales.

#### Captura D - Cronograma/Roadmap EHAPP

![Cronograma EHAPP](docs/02%20Planificaci%C3%B3n/evidencias/evidencia-04-tablero.png)

Aunque el nombre dice tablero, muestra cronograma de siete épicas y barras de Sprints 1-3. Acredita Roadmap visible, no tablero Scrum. Las fechas representadas deben conciliarse con el calendario real.

#### Captura E - Release histórica SCRUM

![Release histórica sin actividades](docs/02%20Planificaci%C3%B3n/evidencias/evidencia-05-release.png)

Muestra v1.0.0-MVP en UNRELEASED y Sin actividades. Acredita existencia de una versión en ese espacio; no asociación de historias, avance ni publicación. La captura definitiva debe mostrar Fix Version e issues del mismo proyecto consolidado.

[README principal](README.md)

## Avance posterior: asignaciones y recorrido

Se implementó asignación manual de pedidos con coordenadas a repartidor y vehículo, y visualización del recorrido por calles con detalles para ADMIN y propietario. Ocho pruebas API y once Flutter aprobadas; prueba real OSRM y comprobación en navegador. La cuenta repartidor tiene ahora un perfil y ruta de demostración; sus datos ficticios no representan datos reales. Aún no acredita algoritmo genético, tráfico/GPS en vivo, entrega/incidencias ni APK independiente. Adjuntar las evidencias nuevas al trabajo correspondiente; no cerrar ceremonias ni historias automáticamente. Detalle: D:\UC\App\ecologistica\evidencias\ASIGNACION_Y_MAPA.md.
