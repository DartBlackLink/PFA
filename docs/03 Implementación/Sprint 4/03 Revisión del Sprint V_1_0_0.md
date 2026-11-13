# Revisión del Sprint 4

**Nombre del proyecto:** EcoLogística Huancayo. **Líder:** Jordy Steve Chancasanampa Torres. **Versión:** 1.0.0. **Corte documental:** 13/11/2026.

## Historias de Usuario completadas en este Sprint

En este corte **no se atribuyen historias completadas o SP aceptados al Sprint 4**. Se preparó su revisión con dos historias y un enabler propuestos, aún sin asignación administrativa: EHAPP-15/US-006 mapa (5 SP), EHAPP-16/US-007 dashboard (5 SP) y EHAPP-14/EN-002 rendimiento (5 SP). El responsable aceptó esta propuesta documental; eso no constituye una Review ni un cambio de Jira.

El mapa, la optimización y las entregas demostrados en el [Sprint 3](../Sprint%203/03%20Revisi%C3%B3n%20del%20Sprint%20V_1_0_0.md) son antecedentes reutilizables. El Sprint 4 debe registrar qué se completa o revalida frente a sus propios criterios, sin presentar ese trabajo previo como nuevo.

## Demostración del trabajo completado

**Trabajo realizado ahora:** consulta de Jira y de las plantillas, definición del alcance, criterios de aceptación, protocolo de rendimiento y anexos de calidad. La siguiente secuencia prepara la futura demostración funcional; no se afirma que se haya ejecutado en este sprint.

1. Identificar la versión publicada/candidata, ingresar como ADMIN y seleccionar una planificación real de demostración de Huancayo.
2. Mostrar origen, secuencia de entregas y trazado vial; contrastar datos y listado accesible con lo guardado en PostgreSQL.
3. Mostrar los cuatro indicadores de esa misma planificación; explicar unidades, factores, momento de cálculo y datos no disponibles. Distinguir ventana prevista de entrega real.
4. Ingresar como REPARTIDOR, consultar solo la ruta propia y demostrar el rechazo de un recurso ajeno. No sustituir una ubicación ausente para obtener un mapa.
5. Mostrar las mediciones integradas 150/15 y reoptimización con su dataset, semilla, entorno y validación de restricciones. No extrapolar un ensayo pequeño.
6. Presentar resultados de calidad, seguridad y accesibilidad de esa versión, incluyendo fallos y medidas correctivas, y registrar la decisión real de aceptación.

### Criterios de aceptación preparados

Todos están **definidos para validación S4**; no significan pruebas ejecutadas. GOLD comprueba la cadena completa; feliz una operación válida ordinaria; infeliz un rechazo; borde el comportamiento en un límite.

| ID / tipo | Dado | Cuando | Entonces / evidencia exigida |
|---|---|---|---|
| S4-MAP-GOLD | Plan confirmado con paradas públicas válidas de Huancayo y roles ADMIN/propietario | ADMIN consulta mapa y REPARTIDOR abre la misma ruta | Origen, orden, paradas y geometría corresponden al mismo ID/versión. Capturas por rol y lectura API concordantes. |
| S4-MAP-FELIZ | Ruta válida con una entrega | Se centra y amplía el recorrido | La parada y el origen siguen identificables; la lista textual conserva dirección, orden y estado. |
| S4-MAP-INFELIZ | Parada sin coordenadas, trazado fuera de zona o recurso ajeno | Se solicita representar/consultar | Error controlado sin inventar ubicación ni exponer información ajena; no cambia la asignación. |
| S4-MAP-BORDE | Destino dentro del límite operativo o fallo de teselas | Se consulta la ruta | Se valida el recorrido completo y se conserva la lista; un fallo del mapa base no se presenta como pérdida de los datos guardados. |
| S4-DASH-GOLD | Plan seleccionado, datos completos y entregas registradas | ADMIN consulta indicadores | Distancia, litros y kg CO₂ se recalculan con los factores conservados; cumplimiento distingue previsión y tiempos reales. Comparación numérica con datos de origen. |
| S4-DASH-FELIZ | Dos planes válidos | Se cambia la selección | Cambian contexto y métricas juntos; no quedan valores mezclados ni se suman versiones como viajes nuevos. |
| S4-DASH-INFELIZ | Falta consumo/factor válido o no hay una entrega real para evaluar | Se carga el resumen | Indicador afectado no disponible con motivo; no se convierte ausencia en cero ni en cumplimiento. |
| S4-DASH-BORDE | Sin rutas, ruta cancelada o versión reemplazada | Se consulta y filtra | Estado vacío coherente; se evita doble conteo. Solo se agregan entidades del alcance elegido. |
| S4-PERF-GOLD | Dataset fijo de 150 pedidos y 15 equipos válidos, red/BD/entorno registrados | Se optimiza y confirma, luego se reoptimiza un cambio controlado | Resultado factible sin duplicados y mediciones integradas: ≤45 s y <30 s respectivamente. Evidencia cruda y resumen, no tiempos inventados. |
| S4-PERF-FELIZ | Dataset fijo de 10 y después 50 pedidos | Se ejecutan cinco semillas por tamaño | Se conserva cada tiempo, resultado, configuración y factibilidad; estadísticas calculadas desde las ejecuciones. |
| S4-PERF-INFELIZ | Problema inviable o proveedor vial no disponible | Se solicita el cálculo | Diagnóstico coherente y ausencia de escritura parcial; inviabilidad y fallo de infraestructura se registran por separado. |
| S4-PERF-BORDE | 150 pedidos/15 equipos, capacidad exacta y final de ventana inclusivo | Se calcula y confirma | Se verifican límites de capacidad/turno/ventana y las paradas únicas; exceder 45 s o alcanzar 30 s en replan no se marca aprobado. |

### Contrato de indicadores que debe verificarse

| Indicador | Definición preparada para EHAPP-16 |
|---|---|
| Distancia | Suma de los kilómetros calculados del recorrido seleccionado; identificar si incluye retorno y qué versión se usa. No equivale a distancia GPS realmente recorrida. |
| Combustible | Para cada recorrido con consumo válido: litros estimados = km / rendimiento en km/L. Usar los parámetros conservados con el cálculo, no aplicar cambios actuales de la flota a rutas históricas. |
| CO₂ | kg CO₂ estimados = km × factor en kg CO₂/km. Si hay varios equipos, sumar sus resultados individuales. No presentar la estimación como una medición de emisiones. |
| Cumplimiento de ventanas | Separar factibilidad prevista de cumplimiento observado. Para este último: entregas evaluables completadas dentro de su ventana / entregas completadas evaluables ×100; mostrar numerador, denominador y pendientes. Sin entregas evaluables, mostrar no disponible, no 100 %. |

El dashboard debe identificar planificación/versión, alcance, unidad y fecha de cálculo. Los cambios de selección, valores ausentes y rutas canceladas forman parte de los casos de aceptación, no de excepciones que puedan ocultarse.

### Definition of Done y decisión

| Condición | Evidencia que debe revisarse |
|---|---|
| Alcance y criterios | Tres candidatas y calendario registrados en Jira; resultados por cada ID anterior. |
| Calidad y seguridad | Suites, cobertura, análisis y revisión de riesgos enlazados a la versión candidata. |
| Accesibilidad | Contraste, teclado, lector y reflujo comprobados; hallazgos resueltos o aceptación de excepción documentada. |
| Trazabilidad | Fuente, resultado y captura enlazados; revisión técnica por par o adaptación docente registrada, sin inventar otra persona. |
| Aceptación | Fecha, participantes reales, feedback, decisión por historia y acciones. No hay acta de aceptación en este corte. |

## Pendientes

Las tareas concretas de Jira, evidencia visual y ejecución están reunidas en [Acciones para cerrar S4](ACCIONES_PARA_CERRAR_SPRINT4.md). El protocolo de medición está en [Plan de rendimiento](09%20Plan%20de%20validaci%C3%B3n%20del%20rendimiento%20V_1_0_0.md). No se mueve PDF al sprint ni se declara aceptación de EHAPP-13 otra vez.

[Índice del Sprint 4](README.md) · [Volver a Implementación](../README.md)
