# Informe de estado del proyecto — Sprint 4

**Nombre del proyecto:** EcoLogística Huancayo. **Líder:** Jordy Steve Chancasanampa Torres. **Sprint:** 4. **Versión:** 1.0.0. **Fecha:** 13/11/2026.

**Periodo del informe:** 13/11/2026, corte de preparación documental del Sprint 4. El inicio y fin de ejecución se definirán al crear el sprint en Jira; no se usan las fechas de la planificación histórica como si fueran vigentes.

**Objetivo propuesto:** permitir consultar recorridos de Huancayo e indicadores coherentes con una planificación seleccionada y medir el rendimiento integrado del motor, preservando restricciones, permisos y trazabilidad.

## Estado del proyecto

| Variables de control | Descripción del estado |
|---|---|
| Alcance | Expediente preparado para EHAPP-15/US-006 (mapa, 5 SP), EHAPP-16/US-007 (dashboard, 5 SP) y EHAPP-14/EN-002 (rendimiento, 5 SP). Total propuesto 15 SP. Jira no registra Sprint 4 ni aceptación de estos elementos. |
| Cronograma | Corte documental completado el 13/11. Calendario administrativo por acordar. Los hitos son: fijar compromiso → verificar mapa/indicadores → medir rendimiento → revisar evidencia → realizar Review. No se calcula porcentaje de ejecución sin tareas y fechas comprometidas. |
| Costos | Trabajo individual con infraestructura existente. No se aportó un parte de horas o desembolsos exclusivo del Sprint 4; el presupuesto del proyecto no se presenta como gasto ejecutado. |
| Calidad | Criterios, protocolo y anexos preparados. Las suites y Sonar del Sprint 3 son antecedentes fechados, no resultados nuevos del Sprint 4. La nueva aceptación exige evidencia de la versión realmente desplegada. |

### Elementos de línea base

US significa **historia de usuario** y describe una necesidad con valor para un rol. EN significa **enabler** y habilita una capacidad técnica medible. Una clave EHAPP identifica el registro estable de Jira.

| Elemento | Trabajo específico esperado | Cierre verificable |
|---|---|---|
| EHAPP-15 / US-006 | Mostrar origen, recorrido vial y entregas; lista equivalente al mapa y consulta según propietario. | Geometría y paradas coherentes con la ruta seleccionada; error controlado si falta ubicación; sin acceso a rutas ajenas. |
| EHAPP-16 / US-007 | Mostrar distancia, combustible y CO₂ estimados y cumplimiento de ventanas con alcance y fecha identificados. | Cifras recalculables desde datos de esa planificación; ausencias visibles; no duplicar rutas canceladas o versiones históricas. |
| EHAPP-14 / EN-002 | Medir optimización/reoptimización de extremo a extremo con dataset y entorno registrados. | Hasta 150 pedidos/15 equipos: optimización ≤45 s y reoptimización <30 s; factibilidad verificada. Un exceso se registra como resultado no conforme. |

## Cambios y mejoras documentales realizados

| Cambio | Motivo y efecto |
|---|---|
| Separar Sprint 4 de Sprint 3 | La optimización ya aparece como EHAPP-13 en S3. Este expediente evalúa su consumo en mapa/dashboard y el rendimiento, sin duplicar SP. |
| Usar las claves actuales de Jira | En LEG-V1.2, US-007 significaba optimización; actualmente significa dashboard. Los nuevos archivos citan EHAPP y el nombre para evitar confusión. |
| Definir cuatro clases de aceptación | Se incluyen operación completa GOLD, alternativa válida, rechazo y límites; abrir una pantalla no acredita el criterio. |
| Añadir anexos propios | Calidad, OWASP, WCAG, trazabilidad y rendimiento responden a Flutter/FastAPI/PostgreSQL y no copian resultados del ejemplo. |
| Separar acciones y resultados | Jira, capturas y pruebas futuras quedan en una lista de cierre. No se crea un historial de ejecución ficticio. |

No se cambió código, base de datos, Docker, Android ni estados de Jira en esta preparación.

## Riesgos

| Riesgo | Responsable | Mitigación |
|---|---|---|
| Confundir una propuesta de alcance con un sprint comprometido | Jordy | Crear S4 con fechas acordadas y asociar únicamente las candidatas aprobadas; conservar la consulta inicial. |
| Publicar métricas de otra versión o medir solo el algoritmo | Jordy | Identificar commit, build, dataset, semilla, red y PostgreSQL en cada ejecución; separar motor de flujo integrado. |
| Presentar combustible/CO₂ o congestión como datos medidos | Jordy | Etiquetar estimaciones, factores y fuente; no afirmar tráfico en vivo ni ahorro sin comparación equivalente. |
| Reutilizar una geometría de Lima o una ubicación supuesta | Jordy | Comprobar todos los puntos y el recorrido en el ámbito aprobado de Huancayo; conservar error si faltan coordenadas. |
| Convertir un resumen de cantidades en dashboard ambiental terminado | Jordy | Validar cada indicador de EHAPP-16; los conteos de pedidos/vehículos no sustituyen combustible, CO₂ ni ventanas. |

## Próximos avances

1. Registrar el calendario y el compromiso en Jira siguiendo las [acciones de cierre](ACCIONES_PARA_CERRAR_SPRINT4.md).
2. Contrastar cada criterio de la [Revisión](03%20Revisi%C3%B3n%20del%20Sprint%20V_1_0_0.md) con la versión de entrega, sin modificar la aplicación dentro de este encargo documental.
3. Ejecutar posteriormente las comprobaciones faltantes y conservar resultados válidos y fallidos; realizar Review y retrospectiva con participantes y decisiones reales.

## Notas

El [índice](README.md) fija fuentes y alcance. El [registro de impedimentos](02%20Registro%20de%20Impedimentos%20V_1_0_0.md) no se llena con riesgos, tareas de captura o defectos ordinarios. [Volver a Implementación](../README.md).
