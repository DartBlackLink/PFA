[← Volver al README principal](../../README.md)

# Transformación Ágil del Proyecto

## 1. Metadatos

| Campo | Información |
|---|---|
| Proyecto | EcoLogística Lima - Optimizador de Rutas Sostenibles para DistriRápido S.A.C. |
| Integrante | Jordy Steve Chancasanampa Torres |
| Versión | 1.0.0 |
| Estado | Línea base de planificación ágil |
| Ruta | `docs/02 Planificación/01 Transformando a ágil V_1_0_0.md` |

## 2. Objetivo

Transformar la línea base de requisitos de `docs/01 Inicio/` en un backlog ágil **ejecutable por un solo integrante**, conservando trazabilidad y evitando que el MVP crezca más allá de lo necesario para demostrar valor.

La transformación aplica cuatro reglas: agrupar comportamientos relacionados sin crear historias artificialmente pequeñas; mantener como `Must` únicamente el flujo esencial; convertir calidad, seguridad, rendimiento y arquitectura en Enablers o criterios transversales; y conservar capacidades secundarias como `Could / Post-MVP` sin eliminarlas de la trazabilidad.

## 3. Línea base de alcance

### Incluido en el MVP

- autenticación y autorización básica;
- flota;
- conductores básicos;
- pedidos;
- optimización con una metaheurística principal;
- mapa;
- dashboard;
- reporte PDF básico;
- incidencia y reoptimización controlada si el núcleo queda estable.

### No comprometido para la primera versión

- múltiples metaheurísticas;
- tráfico externo obligatorio en tiempo real;
- portal completo de clientes;
- compensación de carbono avanzada;
- microservicios, colas, caché distribuida o PostGIS obligatorio;
- integraciones institucionales en tiempo real.

## 4. Épicas

| ID | Épica | Propósito | Prioridad |
|---|---|---|---|
| EP-01 | Acceso seguro | Permitir acceso autenticado con permisos mínimos por rol. | Must |
| EP-02 | Operación logística | Administrar flota, conductores y pedidos necesarios para planificar. | Must |
| EP-03 | Optimización y respuesta a cambios | Generar rutas válidas y recalcularlas ante cambios controlados. | Must/Should |
| EP-04 | Visualización e indicadores | Mostrar rutas, KPIs y evidencia de sostenibilidad. | Must/Should |
| EP-05 | Calidad técnica y entrega | Asegurar rendimiento, seguridad, accesibilidad, pruebas y documentación. | Must |

## 5. Mapeo RF → Épicas → Historias

| RF existente | Historia ágil | Épica | Alcance |
|---|---|---|---|
| RF-001, RF-002, RF-003 | US-002 Gestión de flota | EP-02 | MVP |
| RF-004, RF-005 | US-004 Gestión de pedidos | EP-02 | MVP |
| RF-006 | US-005 Generar rutas optimizadas | EP-03 | MVP |
| RF-007 | US-006 Visualizar rutas | EP-04 | MVP |
| RF-008 | US-007 Consultar dashboard | EP-04 | MVP |
| RF-009 | US-008 Generar reporte PDF | EP-04 | MVP |
| RF-010 | US-009 Reoptimizar planificación | EP-03 | Should |
| RF-011, RF-012 | US-003 Gestión básica de conductores | EP-02 | MVP |
| RF-013 | US-011 Preferencias de cliente | EP-02 | Post-MVP |
| RF-014 | US-012 Compensación de carbono | EP-04 | Post-MVP |
| RF-015 | US-010 Registrar incidencia | EP-03 | Should |
| RF-016 | US-009 Reoptimizar planificación | EP-03 | Should |
| RF-017, RF-018 | US-001 Acceso y autorización | EP-01 | MVP |

## 6. Mapeo RNF → Enablers / DoD

| Grupo de calidad | Tratamiento ágil | Aplicación |
|---|---|---|
| Rendimiento y reoptimización | EN-002 | Pruebas del motor con umbrales de 45 s y 30 s. |
| Seguridad y privacidad | EN-003 | Autenticación, autorización, validación y pruebas negativas. |
| Accesibilidad, usabilidad y conectividad | EN-004 | Responsive, WCAG aplicable y flujo simplificado. |
| Compatibilidad, mantenibilidad y arquitectura | EN-001 | Monolito modular, API REST y configuración reproducible. |
| Pruebas, documentación y trazabilidad | EN-005 + DoD | Cobertura, revisión, OpenAPI, evidencias y control de cambios. |
| Capacidad y disponibilidad | Criterio de diseño/prueba | Se valida como atributo; no exige infraestructura empresarial real. |

# 7. Historias de Usuario

## US-001 — Acceso y autorización básica
**Épica Relacionada:** EP-01 — Acceso seguro  
**Prioridad:** Must · **Story Points:** 3

**Como** usuario autorizado, **quiero** iniciar sesión y acceder únicamente a las funciones de mi perfil, **para** utilizar la plataforma sin exponer información u operaciones que no me corresponden.

**Escenario: inicio de sesión válido**  
**Dado** que existe una cuenta activa con credenciales válidas  
**Cuando** el usuario inicia sesión  
**Entonces** el sistema crea una sesión autenticada y muestra las funciones permitidas por su rol.

**Escenario: acceso no autorizado**  
**Dado** que un usuario intenta ejecutar una operación no permitida  
**Cuando** el backend valida su rol  
**Entonces** el sistema rechaza la operación sin exponer datos sensibles.

---

## US-002 — Gestión de flota
**Épica Relacionada:** EP-02 — Operación logística  
**Prioridad:** Must · **Story Points:** 5

**Como** coordinador logístico, **quiero** registrar, consultar, actualizar y cambiar el estado operativo de los vehículos, **para** disponer de una flota válida antes de generar rutas.

**Escenario: registrar vehículo válido**  
**Dado** que se proporciona placa única, tipo, capacidad, consumo y factor de emisión válidos  
**Cuando** se confirma el registro  
**Entonces** el vehículo queda disponible para futuras planificaciones.

**Escenario: impedir vehículo inválido**  
**Dado** que falta un dato obligatorio o la placa ya existe  
**Cuando** se intenta guardar  
**Entonces** el sistema rechaza el registro e identifica el dato que debe corregirse.

---

## US-003 — Gestión básica de conductores
**Épica Relacionada:** EP-02 — Operación logística  
**Prioridad:** Must · **Story Points:** 3

**Como** coordinador logístico, **quiero** registrar conductores y su disponibilidad operativa, **para** asignar únicamente personas habilitadas a las rutas del MVP.

**Escenario: registrar conductor**  
**Dado** que se proporcionan identificación, licencia y disponibilidad válidas  
**Cuando** el coordinador confirma el registro  
**Entonces** el conductor queda disponible para la planificación.

**Escenario: disponibilidad incompatible**  
**Dado** que la disponibilidad registrada es inválida o incompatible  
**Cuando** se intenta asignar al conductor  
**Entonces** el sistema informa el conflicto y evita la asignación.

---

## US-004 — Gestión de pedidos
**Épica Relacionada:** EP-02 — Operación logística  
**Prioridad:** Must · **Story Points:** 5

**Como** coordinador logístico, **quiero** registrar y actualizar pedidos con ubicación, carga y ventana de tiempo, **para** disponer de entradas válidas para el motor de optimización.

**Escenario: registrar pedido completo**  
**Dado** que el pedido contiene ubicación utilizable, peso/volumen, prioridad y ventana válida  
**Cuando** se registra  
**Entonces** queda disponible para la siguiente optimización.

**Escenario: rechazar pedido incompleto**  
**Dado** que falta ubicación, capacidad requerida o ventana válida  
**Cuando** se intenta confirmar  
**Entonces** el sistema rechaza el pedido e informa los campos pendientes.

---

## US-005 — Generar rutas optimizadas
**Épica Relacionada:** EP-03 — Optimización y respuesta a cambios  
**Prioridad:** Must · **Story Points:** 13

**Como** coordinador logístico, **quiero** generar rutas mediante un Algoritmo Genético, **para** obtener una planificación válida que considere capacidad, distancia y ventanas de tiempo.

**Escenario: generar solución válida**  
**Dado** que existen pedidos, vehículos y conductores elegibles  
**Cuando** se ejecuta la optimización  
**Entonces** el sistema devuelve rutas que respetan las restricciones obligatorias.

**Escenario: escenario sin solución factible**  
**Dado** que la demanda o restricciones hacen imposible una asignación válida  
**Cuando** se ejecuta el algoritmo  
**Entonces** el sistema informa que no existe solución factible y no presenta una ruta inválida como correcta.

---

## US-006 — Visualizar rutas en mapa
**Épica Relacionada:** EP-04 — Visualización e indicadores  
**Prioridad:** Must · **Story Points:** 5

**Como** coordinador o conductor, **quiero** visualizar la ruta y sus puntos de entrega en un mapa, **para** comprender la secuencia propuesta.

**Escenario: mostrar ruta generada**  
**Dado** que existe una planificación válida  
**Cuando** el usuario abre la vista de mapa  
**Entonces** se muestran recorrido y puntos de entrega.

**Escenario: coordenadas inválidas**  
**Dado** que una parada carece de coordenadas válidas  
**Cuando** se intenta representar  
**Entonces** el sistema informa la inconsistencia sin inventar una ubicación.

---

## US-007 — Consultar dashboard esencial
**Épica Relacionada:** EP-04 — Visualización e indicadores  
**Prioridad:** Must · **Story Points:** 5

**Como** gerencia o coordinador, **quiero** consultar indicadores resumidos, **para** evaluar eficiencia operativa y ambiental.

**Escenario: mostrar indicadores**  
**Dado** que una ruta posee datos calculados  
**Cuando** se consulta el dashboard  
**Entonces** se muestran distancia, combustible estimado, CO₂ estimado y cumplimiento de ventanas.

**Escenario: dato insuficiente**  
**Dado** que falta un parámetro necesario  
**Cuando** se carga el dashboard  
**Entonces** el indicador afectado se marca como no disponible sin inventar un valor.

---

## US-008 — Generar reporte PDF básico
**Épica Relacionada:** EP-04 — Visualización e indicadores  
**Prioridad:** Should · **Story Points:** 5

**Como** gerencia o auditor, **quiero** descargar un reporte básico, **para** conservar evidencia de los resultados.

**Escenario: generar reporte**  
**Dado** que existe una planificación con indicadores  
**Cuando** se solicita el reporte  
**Entonces** se genera un PDF con identificación e indicadores principales.

**Escenario: impedir reporte sin planificación**  
**Dado** que no existe una planificación válida seleccionada  
**Cuando** se solicita el PDF  
**Entonces** se informa que primero debe seleccionarse o generarse una planificación.

---

## US-009 — Reoptimizar una planificación
**Épica Relacionada:** EP-03 — Optimización y respuesta a cambios  
**Prioridad:** Should · **Story Points:** 8

**Como** coordinador logístico, **quiero** recalcular una planificación después de un cambio operativo, **para** obtener una nueva ruta sin reconstruir manualmente toda la planificación.

**Escenario: cambio que afecta la ruta**  
**Dado** que existe una ruta vigente y un cambio relevante  
**Cuando** se solicita reoptimizar  
**Entonces** el sistema reutiliza el motor y conserva trazabilidad con la ejecución anterior.

**Escenario: cambio sin datos suficientes**  
**Dado** que el evento no contiene datos mínimos  
**Cuando** se solicita reoptimizar  
**Entonces** el sistema conserva la ruta vigente e informa la causa.

---

## US-010 — Registrar incidencia operativa
**Épica Relacionada:** EP-03 — Optimización y respuesta a cambios  
**Prioridad:** Should · **Story Points:** 3

**Como** coordinador o conductor autorizado, **quiero** registrar una incidencia básica, **para** dejar evidencia de un evento que puede afectar la planificación.

**Escenario: incidencia válida**  
**Dado** que se proporciona tipo, momento, ubicación y descripción mínima  
**Cuando** se confirma  
**Entonces** la incidencia se almacena con su origen.

**Escenario: incidencia incompleta**  
**Dado** que faltan datos mínimos  
**Cuando** se intenta registrar  
**Entonces** el sistema rechaza el registro e informa los campos requeridos.

---

## US-011 — Preferencias de cliente
**Épica Relacionada:** EP-02 — Operación logística  
**Prioridad:** Could / Post-MVP · **Story Points:** 3

**Como** coordinador, **quiero** registrar preferencias simples de entrega, **para** conservar horarios o puntos de referencia sin construir un portal completo.

**Escenario: preferencia válida**  
**Dado** que existe un cliente y una preferencia válida  
**Cuando** se guarda  
**Entonces** queda asociada al cliente.

**Escenario: preferencia incoherente**  
**Dado** que contiene un horario inválido  
**Cuando** se intenta guardar  
**Entonces** se rechaza e informa la inconsistencia.

---

## US-012 — Compensación de carbono simplificada
**Épica Relacionada:** EP-04 — Visualización e indicadores  
**Prioridad:** Could / Post-MVP · **Story Points:** 5

**Como** gerencia, **quiero** consultar una equivalencia ambiental basada en parámetros configurados, **para** contextualizar emisiones sin implementar un mercado real de créditos.

**Escenario: equivalencia disponible**  
**Dado** que existen emisiones y factor documentado  
**Cuando** se solicita la estimación  
**Entonces** se muestra la equivalencia e identifica el parámetro usado.

**Escenario: falta de parámetro**  
**Dado** que no existe un factor válido  
**Cuando** se solicita el cálculo  
**Entonces** se informa que no está disponible y no se inventa resultado.

# 8. Historias Técnicas / Enablers

## EN-001 — Base técnica reproducible
**Épica:** EP-05 · **Prioridad:** Must · **SP:** 3

Objetivo: disponer de React, FastAPI y PostgreSQL como monolito modular, con configuración separada.

**Escenario: arranque reproducible**  
**Dado** un entorno limpio con dependencias documentadas  
**Cuando** se siguen los pasos de instalación  
**Entonces** frontend, API y base de datos pueden ejecutarse sin modificar código fuente.

**Escenario: secretos fuera del repositorio**  
**Dado** que se necesitan credenciales  
**Cuando** se configura el entorno  
**Entonces** se cargan mediante variables y no se versionan en Git.

---

## EN-002 — Rendimiento del motor
**Épica:** EP-05 · **Prioridad:** Must · **SP:** 5

**Escenario: optimización dentro del umbral**  
**Dado** un dataset de hasta 150 pedidos y 15 vehículos  
**Cuando** se ejecuta la prueba  
**Entonces** la solución válida se compara con el máximo objetivo de 45 segundos.

**Escenario: reoptimización medida**  
**Dado** un escenario de cambio crítico preparado  
**Cuando** se reoptimiza  
**Entonces** se registra el tiempo y se compara con el objetivo menor a 30 segundos.

---

## EN-003 — Seguridad y privacidad
**Épica:** EP-05 · **Prioridad:** Must · **SP:** 5

**Escenario: prueba negativa de autorización**  
**Dado** un usuario sin permiso  
**Cuando** intenta una operación restringida  
**Entonces** la API la deniega y no modifica datos.

**Escenario: entrada maliciosa**  
**Dado** una entrada no válida o potencialmente maliciosa  
**Cuando** llega a la API  
**Entonces** se valida o rechaza antes de una operación insegura.

---

## EN-004 — Accesibilidad y experiencia mínima
**Épica:** EP-05 · **Prioridad:** Should · **SP:** 5

**Escenario: flujo responsive**  
**Dado** un tamaño de pantalla móvil objetivo  
**Cuando** se ejecuta una tarea crítica  
**Entonces** puede completarse sin pérdida de controles esenciales.

**Escenario: no depender solo del color**  
**Dado** un estado o alerta  
**Cuando** se muestra  
**Entonces** se comunica mediante texto o icono además del color.

---

## EN-005 — Pruebas, documentación y entrega
**Épica:** EP-05 · **Prioridad:** Must · **SP:** 3

**Escenario: historia candidata a Done**  
**Dado** que terminó su implementación  
**Cuando** se evalúa contra el DoD  
**Entonces** existe evidencia de aceptación, pruebas, revisión y documentación aplicable.

**Escenario: cambio en API**  
**Dado** que una historia modifica un endpoint  
**Cuando** se integra  
**Entonces** OpenAPI/Swagger queda actualizado.

# 9. Definition of Done Global

Una Historia de Usuario o Enabler se considera `Done` cuando, según aplique:

1. sus criterios BDD están aprobados;
2. las pruebas unitarias de la lógica desarrollada alcanzan **≥ 80 %** de cobertura en el alcance medido;
3. el análisis estático no reporta vulnerabilidades críticas abiertas;
4. existe revisión mediante Pull Request; al ser un proyecto individual, puede documentarse una auto-revisión estructurada hasta contar con un par técnico;
5. el incremento es ejecutable en staging/pruebas;
6. OpenAPI/Swagger se actualiza cuando cambia la API;
7. existe evidencia de prueba;
8. se actualiza trazabilidad si cambia RF/RNF/regla/arquitectura;
9. no existen defectos bloqueantes conocidos;
10. el ítem está asociado a su Épica y versión Jira.

## 10. Política de control de alcance

- `Must`: compromiso del MVP.
- `Should`: después de estabilizar el flujo principal.
- `Could / Post-MVP`: trazado, pero no comprometido inicialmente.
- No se incorpora integración externa mientras el flujo local equivalente no funcione.
- No se implementa una segunda metaheurística mientras el Algoritmo Genético no esté probado.

## 11. Resultado

La transformación conserva la cobertura documental existente y reduce el compromiso de implementación a un conjunto que puede administrar un único integrante.

[← Volver al README principal](../../README.md)
