EcoLogística Lima

Optimizador de Rutas Sostenibles para DistriRápido S.A.C.

Proyecto académico individual orientado al desarrollo de un MVP web funcional para apoyar la planificación de rutas de reparto de última milla en Lima Metropolitana.

Criterio rector: desarrollar primero un flujo completo, integrado, probado y demostrable.
Las funcionalidades secundarias no deben ampliar el alcance mientras exista una funcionalidad esencial incompleta.

1. Descripción del proyecto

EcoLogística Lima busca apoyar la planificación de reparto de DistriRápido S.A.C., empresa ficticia del caso académico, mediante una plataforma web capaz de gestionar información operativa, generar rutas optimizadas, visualizar recorridos e indicadores básicos de sostenibilidad.

La solución se desarrolla considerando el contexto de Lima Metropolitana, donde influyen factores como:

congestión vehicular;

ventanas de tiempo de entrega;

consumo de combustible;

emisiones de CO₂;

capacidad de los vehículos;

disponibilidad de conductores;

restricciones operativas y de seguridad;

disponibilidad variable de datos externos.

El proyecto se desarrolla por un solo integrante, por lo que se mantiene un alcance controlado y una arquitectura simple.

2. Objetivo general

Diseñar, desarrollar e implementar un MVP web que permita:

administrar los datos operativos básicos;

generar rutas válidas mediante una metaheurística;

visualizar las rutas en un mapa interactivo;

consultar indicadores de eficiencia y sostenibilidad;

conservar evidencia mediante reportes y pruebas;

responder a cambios operativos mediante reoptimización controlada, si el núcleo del MVP se encuentra estable.

3. Alcance del MVP

3.1 Funcionalidades esenciales

Prioridad

Capacidad

Alcance

Must

Autenticación y autorización

Inicio de sesión y permisos básicos por rol.

Must

Gestión de flota

Registrar, consultar, actualizar y cambiar estado de vehículos.

Must

Gestión básica de conductores

Registrar conductores y disponibilidad necesaria para la planificación.

Must

Gestión de pedidos

Registrar pedidos con ubicación, carga y ventana de tiempo.

Must

Optimización de rutas

Utilizar una sola metaheurística principal: Algoritmo Genético.

Must

Visualización en mapa

Mostrar rutas y puntos de entrega con Leaflet/OpenStreetMap.

Must

Dashboard

Mostrar distancia, combustible estimado, CO₂ estimado y cumplimiento de ventanas.

Should

Reporte PDF

Generar un reporte básico de una planificación.

Should

Incidencias

Registrar eventos operativos que puedan afectar una ruta.

Should

Reoptimización

Recalcular una planificación reutilizando el mismo motor de optimización.

3.2 Capacidades Post-MVP

Las siguientes funcionalidades permanecen documentadas, pero no forman parte del compromiso inicial de implementación:

múltiples metaheurísticas;

integración obligatoria con tráfico en tiempo real;

portal completo de autoservicio para clientes;

compensación avanzada de carbono;

integración institucional en tiempo real con MTC, Policía u otras fuentes;

microservicios;

colas de mensajería;

caché distribuida;

PostGIS obligatorio;

telemetría GPS continua;

IoT;

infraestructura empresarial de alta disponibilidad;

escalamiento horizontal implementado físicamente.

4. Usuarios principales del MVP

Para reducir complejidad de implementación, se priorizan tres perfiles operativos:

Administrador / Coordinador

Gestiona flota, conductores, pedidos, planificación y reoptimización.

Conductor

Consulta la información de su ruta y puede registrar incidencias cuando corresponda.

Gerencia / Auditor

Consulta rutas, indicadores y reportes en modo de lectura.

Los demás perfiles identificados en la documentación se mantienen como interesados o actores de contexto.

5. Arquitectura

El MVP utiliza una arquitectura monolítica modular, evitando microservicios innecesarios.

Usuario
  │
  ▼
React + Leaflet
  │
  │ REST / JSON
  ▼
FastAPI + Python
  ├── Seguridad
  ├── Flota
  ├── Conductores
  ├── Pedidos
  ├── Optimización
  ├── Rutas
  ├── Incidencias
  └── Indicadores / Reportes
  │
  ▼
PostgreSQL

Stack tecnológico

Frontend: React + TypeScript/JavaScript

Backend: Python + FastAPI

Base de datos: PostgreSQL

Mapas: Leaflet + OpenStreetMap

API: REST + JSON

Documentación API: OpenAPI / Swagger

Control de versiones: Git + GitHub/GitLab

Gestión ágil: Jira Software

Modelado: Mermaid + Modelo C4

6. Estrategia de optimización

El MVP implementará una sola metaheurística principal:

Algoritmo Genético

La función de evaluación considerará como mínimo:

distancia total;

capacidad vehicular;

ventanas de tiempo;

penalización por entregas tardías;

combustible estimado;

CO₂ estimado.

El sistema deberá trabajar primero con datos locales y controlados.

La integración con servicios externos de tráfico será opcional. Si no existe disponibilidad suficiente, se utilizarán datos simulados o carga manual.

7. Criterios técnicos principales

El MVP debe demostrar:

solución válida para el escenario de prueba;

optimización en un máximo objetivo de 45 segundos para hasta 150 pedidos y 15 vehículos;

reoptimización con objetivo menor a 30 segundos en escenarios controlados;

interfaz responsive;

controles básicos de seguridad;

autorización en backend;

accesibilidad considerada bajo WCAG 2.1 AA;

documentación de API mediante Swagger/OpenAPI;

pruebas funcionales;

pruebas de rendimiento;

evidencia reproducible;

trazabilidad entre requisitos, historias, pruebas y arquitectura.

Los objetivos de capacidad de mayor escala se consideran criterios de diseño y evaluación, no una obligación de desplegar infraestructura empresarial real.

8. Estrategia de desarrollo

El proyecto se desarrolla durante 14 semanas.

La planificación ágil utiliza Sprints de 2 semanas.

Sprint

Objetivo principal

Sprint 1

Base técnica y acceso seguro

Sprint 2

Flota, conductores y pedidos

Sprint 3

Primera optimización válida

Sprint 4

Mapa y dashboard

Sprint 5

Reporte e incidencias

Sprint 6

Reoptimización, rendimiento y seguridad

Sprint 7

Pruebas finales, documentación y preparación de entrega

Regla de control de alcance

Ninguna funcionalidad Post-MVP se incorpora mientras exista una funcionalidad Must incompleta, sin prueba o sin integración.

9. Gestión ágil con Jira

El proyecto se administra en Jira Software utilizando Scrum.

Configuración prevista

Proyecto: EcoLogística Lima
Clave sugerida: ECO

Épica
├── Historia de Usuario
│   └── Subtareas <= 8 horas
└── Historia Técnica / Enabler
    └── Subtareas <= 8 horas

Flujo del tablero

To Do
→ In Progress
→ In Review / QA
→ Done

Épicas

ID

Épica

EP-01

Acceso seguro

EP-02

Operación logística

EP-03

Optimización y respuesta a cambios

EP-04

Visualización e indicadores

EP-05

Calidad técnica y entrega

Release

v1.0.0-MVP

Sprint 1

Sprint Goal

Dejar EcoLogística Lima ejecutable de extremo a extremo en ambiente de desarrollo, con autenticación básica y una base técnica reproducible para iniciar el MVP.

Ítems iniciales:

EN-001 — Base técnica reproducible.

US-001 — Acceso y autorización básica.

10. Definition of Done

Una Historia de Usuario o Enabler puede pasar a Done cuando, según corresponda:

cumple sus criterios BDD/Gherkin;

posee evidencia de prueba;

las pruebas unitarias alcanzan ≥ 80 % de cobertura sobre la lógica desarrollada;

no existen vulnerabilidades críticas abiertas en el análisis estático;

existe revisión mediante Pull Request;

el incremento es ejecutable en ambiente de pruebas;

Swagger/OpenAPI está actualizado cuando cambia la API;

la documentación relacionada ha sido actualizada;

no existen defectos bloqueantes conocidos.

11. Estructura del repositorio

.
├── README.md
│
└── docs/
    │
    ├── 01 Inicio/
    │   ├── 01. Selección del enfoque del proyecto V_1_0_0.md
    │   ├── 02. Acta de constitución V_1_0_0.md
    │   ├── 03. Declaración de la visión V_1_0_0.md
    │   ├── 04. Registro de supuestos y restricciones V_1_0_0.md
    │   ├── 05. Registro de interesados V_1_0_0.md
    │   ├── 06. Requisitos funcionales V_1_0_0.md
    │   ├── 07. Requisitos no funcionales V_1_0_0.md
    │   ├── 08. Usuarios V_1_0_0.md
    │   ├── 09. Reglas de negocio V_1_0_0.md
    │   ├── 10. Stack tecnológico V_1_0_0.md
    │   ├── 11. Base de datos V_1_0_0.md
    │   ├── 12. Modelo C4 V_1_0_0.md
    │   └── 13. Restricciones V_1_0_0.md
    │
    └── 02 Planificación/
        ├── 01 Transformando a ágil V_1_0_0.md
        ├── 02 Artefactos Jira V_1_0_0.md
        ├── 03 Registro de riesgos V_1_0_0.md
        └── 04 Presupuesto del proyecto V_1_0_0.md

12. Fase 01 — Inicio

Documentación de análisis y línea base del proyecto.

Cada documento puede abrirse directamente desde este README y mantiene el orden lógico de elaboración del proyecto.

12.1 Navegación de documentos

01. Selección del enfoque del proyecto V_1_0_0.md

Define y justifica el enfoque de gestión del proyecto.

Navegación: README → 01 Selección del enfoque → 02 Acta de constitución

02. Acta de constitución V_1_0_0.md

Formaliza propósito, objetivos, alcance, criterios de éxito y dirección del proyecto.

Navegación: 01 Selección del enfoque → 02 Acta de constitución → 03 Declaración de la visión

03. Declaración de la visión V_1_0_0.md

Define la visión del producto, usuarios objetivo, necesidades y propuesta de valor.

Navegación: 02 Acta de constitución → 03 Declaración de la visión → 04 Registro de supuestos y restricciones

04. Registro de supuestos y restricciones V_1_0_0.md

Identifica supuestos, restricciones, impacto y mecanismos de control.

Navegación: 03 Declaración de la visión → 04 Supuestos y restricciones → 05 Registro de interesados

05. Registro de interesados V_1_0_0.md

Identifica actores, nivel de interés, influencia y estrategia de participación.

Navegación: 04 Supuestos y restricciones → 05 Registro de interesados → 06 Requisitos funcionales

06. Requisitos funcionales V_1_0_0.md

Contiene los requisitos funcionales atómicos, prioridades, criterios BDD y trazabilidad.

Navegación: 05 Registro de interesados → 06 Requisitos funcionales → 07 Requisitos no funcionales

07. Requisitos no funcionales V_1_0_0.md

Define rendimiento, seguridad, accesibilidad, disponibilidad, usabilidad y calidad.

Navegación: 06 Requisitos funcionales → 07 Requisitos no funcionales → 08 Usuarios

08. Usuarios V_1_0_0.md

Identifica perfiles, actores, necesidades y controles RBAC/ABAC.

Navegación: 07 Requisitos no funcionales → 08 Usuarios → 09 Reglas de negocio

09. Reglas de negocio V_1_0_0.md

Formaliza políticas, validaciones y condiciones que gobiernan el sistema.

Navegación: 08 Usuarios → 09 Reglas de negocio → 10 Stack tecnológico

10. Stack tecnológico V_1_0_0.md

Justifica las tecnologías seleccionadas para frontend, backend, datos y mapas.

Navegación: 09 Reglas de negocio → 10 Stack tecnológico → 11 Base de datos

11. Base de datos V_1_0_0.md

Define el diseño de persistencia y la trazabilidad de la información del MVP.

Navegación: 10 Stack tecnológico → 11 Base de datos → 12 Modelo C4

12. Modelo C4 V_1_0_0.md

Describe contexto, contenedores, componentes y decisiones arquitectónicas.

Navegación: 11 Base de datos → 12 Modelo C4 → 13 Restricciones

13. Restricciones V_1_0_0.md

Consolida restricciones técnicas, económicas, ambientales, normativas y operativas.

Navegación: 12 Modelo C4 → 13 Restricciones → 01 Transformando a ágil

12.2 Flujo documental de la Fase 01

README.md
   │
   ▼
01. Selección del enfoque
   │
   ▼
02. Acta de constitución
   │
   ▼
03. Declaración de la visión
   │
   ▼
04. Registro de supuestos y restricciones
   │
   ▼
05. Registro de interesados
   │
   ▼
06. Requisitos funcionales
   │
   ▼
07. Requisitos no funcionales
   │
   ▼
08. Usuarios
   │
   ▼
09. Reglas de negocio
   │
   ▼
10. Stack tecnológico
   │
   ▼
11. Base de datos
   │
   ▼
12. Modelo C4
   │
   ▼
13. Restricciones
   │
   ▼
02 Planificación

13. Fase 02 — Planificación del Proyecto

Artefacto 1

01 Transformando a ágil V_1_0_0.md

Incluye:

Épicas;

Historias de Usuario;

Historias Técnicas / Enablers;

Story Points;

criterios BDD/Gherkin;

trazabilidad RF/RNF;

Definition of Done;

control del alcance.

Artefacto 2

02 Artefactos Jira V_1_0_0.md

Incluye:

configuración Jira;

roadmap;

backlog;

Sprint 1;

Sprint Goal;

tablero Scrum;

Release;

espacios para las cinco evidencias requeridas.

Artefacto 3

03 Registro de riesgos V_1_0_0.md

Incluye:

Probabilidad;

Impacto;

Severidad;

mitigación;

contingencia;

responsable.

Artefacto 4

04 Presupuesto del proyecto V_1_0_0.md

Incluye:

RRHH;

licencias;

herramientas;

infraestructura;

contingencia;

consolidación financiera.

14. Evidencias Jira requeridas

El documento 02 Artefactos Jira V_1_0_0.md deberá incorporar capturas reales de:

Roadmap de Épicas.

Backlog priorizado con Story Points.

Sprint Planning y Sprint Goal.

Tablero Scrum activo.

Gestión de Versiones / Releases.

Las capturas deben estar recortadas únicamente al elemento de Jira que se desea demostrar.

15. Criterio de éxito del MVP

El MVP se considera funcional cuando puede demostrarse el siguiente flujo:

iniciar sesión;

registrar o consultar vehículo;

registrar o consultar conductor;

registrar pedidos;

ejecutar una optimización;

obtener rutas válidas;

visualizar la planificación en un mapa;

consultar indicadores;

generar evidencia mediante dashboard o reporte;

ejecutar una reoptimización controlada si esta capacidad entra en la versión final.

La prioridad es entregar menos funcionalidades, pero completas, integradas, probadas y demostrables.

16. Estado actual

Elemento

Estado

Fase 01 - Inicio

✅ Documentada

Requisitos

✅ Línea base definida

Base de datos

✅ Diseño inicial definido

Modelo C4

✅ Definido

Restricciones

✅ Documentadas

Fase 02 - Planificación

🟡 En incorporación al repositorio

Backlog ágil

✅ Definido

Riesgos

✅ Línea base definida

Presupuesto

✅ Línea base definida

Jira

🟡 Pendiente de configuración y evidencias

Sprint 1

🟡 Pendiente de creación/inicio en Jira

Implementación MVP

⏳ Posterior a consolidación de planificación

17. Información del proyecto

Proyecto: EcoLogística Lima - Optimizador de Rutas Sostenibles para DistriRápido S.A.C.
Integrante: Jordy Steve Chancasanampa Torres
Modalidad: Proyecto individual
Versión documental: 1.0.0
Release objetivo: v1.0.0-MVP