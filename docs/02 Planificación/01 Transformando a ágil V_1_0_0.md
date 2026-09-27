[⌂ README principal](../../README.md) | [← Anterior: 13. Restricciones](../01%20Inicio/13.%20Restricciones%20V_1_0_0.md) | [Siguiente: 02 Artefactos Jira →](02%20Artefactos%20Jira%20V_1_0_0.md)

# 01 Transformando a ágil

## 1. Metadatos

| Campo | Valor |
|---|---|
| Proyecto | **EcoLogística Huancayo - Optimizador de Rutas Sostenibles para DistriRápido S.A.C.** |
| Integrante | **Jordy Steve Chancasanampa Torres** |
| Modalidad | Proyecto individual |
| Fecha | **27/09/2026** |
| Versión | **1.0.0** |
| Marco | Scrum |
| Sprint | 2 semanas |

> **Resumen de la tabla:** resume la identificación y las decisiones base del documento. Permite comprobar que todos los artefactos pertenecen al mismo proyecto, versión e integrante.

## 2. Adaptación Scrum para proyecto individual

| Responsabilidad Scrum | Responsable académico | Aplicación práctica |
|---|---|---|
| Product Owner | Jordy Steve Chancasanampa Torres | Ordena Product Backlog por valor/riesgo. |
| Scrum Master | Jordy Steve Chancasanampa Torres | Mantiene cadencia, impedimentos y retrospectiva. |
| Developer | Jordy Steve Chancasanampa Torres | Diseña, programa, prueba y documenta. |

> **Resumen de la tabla:** es una adaptación por equipo unipersonal, no la estructura ideal de un Scrum Team real. Las responsabilidades se separan conceptualmente aunque recaigan en la misma persona.

## 3. Épicas

| ID | Épica | Alcance |
|---|---|---|
| EP-01 | Acceso y seguridad | Login, RBAC y sesión por canal. |
| EP-02 | Recursos logísticos | Flota y repartidores. |
| EP-03 | Pedidos y clientes | Pedidos, georreferenciación y preferencias. |
| EP-04 | Optimización | VRPTW/Green VRP y reoptimización. |
| EP-05 | Operación de rutas | Mapa Web y ejecución móvil. |
| EP-06 | Sostenibilidad | Dashboard, reportes y compensación. |
| EP-07 | UX/Calidad | Figma, accesibilidad, documentación y QA. |

> **Resumen de la tabla:** las épicas son grandes bloques para Roadmap. Las historias se cuelgan de estas épicas en Jira.

## 4. Product Backlog - Historias de Usuario

| ID | Historia | Épica | Actor | Acción | RF | Sprint |
|---|---|---|---|---|---|---|
| US-001 | Autenticación administrador | EP-01 | Administrador | iniciar sesión en Flutter Web | RF transversal | S1 |
| US-002 | Autenticación repartidor | EP-01 | Repartidor | iniciar sesión en Flutter móvil | RF transversal | S1 |
| US-003 | Gestionar flota | EP-02 | Administrador | registrar y actualizar vehículos | RF-01 | S2 |
| US-004 | Gestionar repartidores | EP-02 | Administrador | registrar repartidores y disponibilidad | RF-08 | S2 |
| US-005 | Gestionar pedidos | EP-03 | Administrador | registrar pedidos con ubicación y ventana | RF-02 | S3 |
| US-006 | Gestionar clientes/preferencias | EP-03 | Administrador | registrar preferencias comunicadas por clientes | RF-09 | S3 |
| US-007 | Generar rutas optimizadas | EP-04 | Administrador | generar rutas sostenibles | RF-03 | S4 |
| US-008 | Visualizar mapa global | EP-05 | Administrador | visualizar rutas y puntos de entrega | RF-04 | S5 |
| US-009 | Consultar mi ruta | EP-05 | Repartidor | ver la ruta asignada y pendientes | RF-04 | S5 |
| US-010 | Actualizar entrega/reportar incidente | EP-05 | Repartidor | actualizar estado y reportar eventos | RF-07 | S5 |
| US-011 | Reoptimizar rutas | EP-04 | Administrador | recalcular ante cambios | RF-07 | S6 |
| US-012 | Consultar dashboard | EP-06 | Administrador | consultar KPIs | RF-05 | S6 |
| US-013 | Generar reporte PDF | EP-06 | Administrador | descargar reporte de sostenibilidad | RF-06 | S6 |
| US-014 | Plan de compensación | EP-06 | Administrador | calcular compensación de CO₂ | RF-10 | S7 |

> **Resumen de la tabla:** convierte RF en trabajo ágil. “Sprint” es planificación inicial y puede cambiar mediante refinamiento sin perder trazabilidad.

## 5. Historias Técnicas / Enablers

| ID | Enabler | SP | Ventana |
|---|---|---:|---|
| EN-001 | Estructura repositorio y dos proyectos Flutter | 3 | S1 |
| EN-002 | Modelo BD y migraciones | 5 | S1 |
| EN-003 | RBAC y controles OWASP | 5 | S1-S7 |
| EN-004 | Benchmark optimizador | 5 | S4-S7 |
| EN-005 | Accesibilidad WCAG | 3 | S1-S7 |
| EN-006 | Escalabilidad y rendimiento API/BD | 5 | S6-S7 |
| EN-007 | Mockups Figma Web/Móvil | 5 | S1-S2 |
| EN-008 | Disponibilidad/contingencia móvil | 5 | S5-S7 |
| EN-009 | OpenAPI y documentación | 3 | S1-S7 |

> **Resumen de la tabla:** los RNF y decisiones de arquitectura no se esconden dentro de historias funcionales; se gestionan como trabajo técnico explícito y/o criterios transversales.

## 6. Plantilla canónica de historia

```text
ID: US-XXX
Título: ...
Épica: EP-XX
Como [rol]
quiero [acción]
para [valor].

Criterio 1
Dado ...
Cuando ...
Entonces ...

Criterio 2
Dado ...
Cuando ...
Entonces ...
```

> **Resumen:** esta plantilla debe copiarse a Jira. Cada historia debe tener al menos dos criterios BDD verificables.

## 7. Definition of Done global

- Criterios BDD cumplidos.
- Cobertura unitaria del módulo ≥80% cuando aplique.
- Integración probada.
- Sin vulnerabilidades críticas conocidas.
- Revisión de código documentada; por ser proyecto individual, se realiza auto-revisión estructurada y revisión docente cuando corresponda.
- OpenAPI/documentación actualizada.
- Migraciones versionadas si cambió BD.
- Mockup Figma respetado si la historia modifica UI.
- RNF aplicables verificados.
- Issue Jira vinculado a evidencia/commit/PR.

## 8. Definition of Ready

Una historia puede entrar a Sprint cuando tiene: actor, valor, criterios BDD, dependencias identificadas, estimación, diseño/mockup suficiente y datos de prueba definidos.

---

[⌂ README principal](../../README.md) | [← Anterior: 13. Restricciones](../01%20Inicio/13.%20Restricciones%20V_1_0_0.md) | [Siguiente: 02 Artefactos Jira →](02%20Artefactos%20Jira%20V_1_0_0.md)
