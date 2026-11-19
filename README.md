# EcoLogística Huancayo

**Web pública:** [Abrir ADMIN / REPARTIDOR](https://ecologistica-huancayo-web.wasmer.app/). Wasmer + Neon; publicación manual verificada el 19/11/2026. Las credenciales se entregan de forma privada.

Proyecto académico de Taller de Proyectos 2. Responsable: Jordy Steve Chancasanampa Torres.

Sistema de planificación y seguimiento de entregas para Huancayo, Junín, y su entorno urbano definido. La consigna original de Lima se conserva como antecedente de la adaptación. La operación usa la zona horaria `America/Lima`.

## Código y documentación

| Carpeta | Contenido |
| --- | --- |
| [apps/web](apps/web/README.md) | Operación ADMIN y REPARTIDOR con Flutter Web. |
| [apps/mobile](apps/mobile/README.md) | Cliente Android del repartidor y pruebas Flutter. |
| [backend](backend/README.md) | FastAPI, permisos, optimización, migraciones y pruebas. |
| [database](database/README.md) | Esquema PostgreSQL y criterios de persistencia. |
| [tools/quality](tools/quality/README.md) | Ejecución y análisis de calidad. |
| [Implementación](docs/03%20Implementaci%C3%B3n/README.md) | Los cuatro entregables de cada sprint, evidencias seleccionadas e histórico. |

Las fuentes de este repositorio son la copia de entrega. El proyecto local de desarrollo y ejecución está en `D:/UC/App/ecologistica`. Para reproducir los componentes, consulta sus instrucciones y configura tus propias credenciales.

### 01 · Inicio

- [01. Selección del enfoque del proyecto](docs/01%20Inicio/01.%20Selecci%C3%B3n%20del%20enfoque%20del%20proyecto%20V_1_2_0.md)
- [02. Acta de constitución](docs/01%20Inicio/02.%20Acta%20de%20constituci%C3%B3n%20V_1_2_0.md)
- [03. Declaración de la visión](docs/01%20Inicio/03.%20Declaraci%C3%B3n%20de%20la%20visi%C3%B3n%20V_1_2_0.md)
- [04. Registro de supuestos y restricciones](docs/01%20Inicio/04.%20Registro%20de%20supuestos%20y%20restricciones%20V_1_2_0.md)
- [05. Registro de interesados](docs/01%20Inicio/05.%20Registro%20de%20interesados%20V_1_2_0.md)
- [06. Requisitos funcionales](docs/01%20Inicio/06.%20Requisitos%20funcionales%20V_1_2_0.md)
- [07. Requisitos no funcionales](docs/01%20Inicio/07.%20Requisitos%20no%20funcionales%20V_1_2_0.md)
- [08. Usuarios](docs/01%20Inicio/08.%20Usuarios%20V_1_2_0.md)
- [09. Reglas de negocio](docs/01%20Inicio/09.%20Reglas%20de%20negocio%20V_1_2_0.md)
- [10. Stack tecnológico](docs/01%20Inicio/10.%20Stack%20tecnol%C3%B3gico%20V_1_2_0.md)
- [11. Base de datos](docs/01%20Inicio/11.%20Base%20de%20datos%20V_1_2_0.md)
- [12. Modelo C4](docs/01%20Inicio/12.%20Modelo%20C4%20V_1_2_0.md)
- [13. Restricciones](docs/01%20Inicio/13.%20Restricciones%20V_1_2_0.md)

### 02 · Planificación

- [01 Transformando a ágil](docs/02%20Planificaci%C3%B3n/01%20Transformando%20a%20%C3%A1gil%20V_1_2_0.md)
- [02 Artefactos Jira](docs/02%20Planificaci%C3%B3n/02%20Artefactos%20Jira%20V_1_2_0.md)
- [03 Registro de riesgos](docs/02%20Planificaci%C3%B3n/03%20Registro%20de%20riesgos%20V_1_2_0.md)
- [04 Presupuesto del proyecto](docs/02%20Planificaci%C3%B3n/04%20Presupuesto%20del%20proyecto%20V_1_2_0.md)

## Estado técnico del Sprint 3

La demostración de Huancayo verificó la generación y asignación de rutas, el reporte de congestión, la aprobación de la versión 2, el acuse del repartidor y la persistencia de las entregas tras reiniciar la API. La verificación del 09/11 registró 83 pruebas Flutter aprobadas. La regresión backend del 08/11 registró 127 pruebas aprobadas y 90,88 % de cobertura. El análisis SonarQube corresponde al corte del 04/11.

El informe conserva los pendientes de reconexión Android, validación en teléfono físico y publicación de la compilación web más reciente. La aceptación académica tiene su propio criterio de cierre.

- [Informe de validación y capturas](docs/03%20Implementaci%C3%B3n/evidencias/20261109-validacion-danleo/CIERRE_DANLEO_20261109.md)
- [Cobertura backend por módulo](docs/03%20Implementaci%C3%B3n/evidencias/20261103-estabilizacion/COBERTURA.md)
- [Evidencia SonarQube](docs/03%20Implementaci%C3%B3n/evidencias/20261104-cierre/SONARQUBE_ACTUAL.md)
- [Línea base de planificación y reconciliación con Jira](docs/03%20Implementaci%C3%B3n/evidencias/RECONCILIACION_20261030.md)

## Documentación del Sprint 4

Actualización documental del 18/11/2026: Sprint 4 está creado en Jira, con dos historias y un habilitador (15 SP originales), En curso y sin fechas oficiales. El expediente conserva los cortes de prueba del 14/17 de noviembre y adopta la estructura de Semana 14. No se declara cierre académico ni nuevas ejecuciones por actualizar los informes.

- [Documentos y anexos del Sprint 4](docs/03%20Implementaci%C3%B3n/Sprint%204/README.md).
- [Acciones de Jira, evidencias y cierre](docs/03%20Implementaci%C3%B3n/Sprint%204/ACCIONES_PARA_CERRAR_SPRINT4.md).


## Actualización web — 14/11/2026

La web incorpora reportes PDF, indicadores, clientes/preferencias y equivalencia con fuente. Se corrigieron la asignación manual, los horarios y el contrato de indicadores; se preservaron los datos y se verificó el ciclo ADMIN → REPARTIDOR → ADMIN → REPARTIDOR por botones.

Regresión compartida: 141 pruebas backend, 93 pruebas Flutter; cobertura backend: 90.03135%. No es un análisis Sonar nuevo ni significa que todos los sprints estén aceptados. Los resultados anteriores de este README son cortes históricos.

- [Distribución de sprints 1–6](docs/03%20Implementaci%C3%B3n/PLAN_FINAL_SPRINTS_WEB.md).
- [Matriz de aceptación de 12 US y 5 EN](docs/03%20Implementaci%C3%B3n/MATRIZ_FINAL_BACKLOG_WEB.md).
- [Sprint 4 actualizado](docs/03%20Implementaci%C3%B3n/Sprint%204/README.md), [Sprint 5](docs/03%20Implementaci%C3%B3n/Sprint%205/README.md), [Sprint 6](docs/03%20Implementaci%C3%B3n/Sprint%206/README.md).
- [Resultados/evidencias](docs/03%20Implementaci%C3%B3n/evidencias/20261114-desarrollo-integral/RESULTADOS.md) y [acciones externas](docs/03%20Implementaci%C3%B3n/ACCIONES_EXTERNAS_Y_CIERRE_WEB.md).

La aplicación activa se ejecuta en D:/UC/App/ecologistica, web http://127.0.0.1:8080. PFA contiene las fuentes y la documentación de entrega; no crea otra base operativa ni incluye credenciales. Consulte INICIAR_WEB.ps1 y OPERACION_LOCAL.md para el arranque configurado.


## Revisión funcional web — 17/11/2026

Se completó nuevamente el ciclo ADMIN/REPARTIDOR con entregas, incidencia, reoptimización y confirmación de recepción. Se corrigieron las validaciones de franjas y el contraste del mapa. Resultado: 141 pruebas backend y 103 Flutter aprobadas; cobertura combinada backend 90,03 %. Los casos y sus límites se detallan en la [matriz de operaciones](docs/03%20Implementaci%C3%B3n/evidencias/20261117-verificacion-final/MATRIZ_OPERACIONES.md) y los [resultados verificables](docs/03%20Implementaci%C3%B3n/evidencias/20261117-verificacion-final/RESULTADOS.md). No es un nuevo análisis SonarQube ni una validación de Android.


## Semana 14 — entregables del Sprint 4

- [01 Revisión del sprint](docs/03%20Implementaci%C3%B3n/Sprint%204/01%20Revisi%C3%B3n%20del%20Sprint%20V_1_0_0.md).
- [02 Retrospectiva del sprint](docs/03%20Implementaci%C3%B3n/Sprint%204/02%20Retrospectiva%20del%20Sprint%20V_1_0_0.md).
- [03 Análisis Playwright](docs/03%20Implementaci%C3%B3n/Sprint%204/03%20Analisis%20PlayWrigth%20V_1_0_0.md).
- [04 Usabilidad SUS](docs/03%20Implementaci%C3%B3n/Sprint%204/04%20Usabilidad%20V_1_0_0.md).
- [Control híbrido](docs/03%20Implementaci%C3%B3n/Sprint%204/10%20Control%20h%C3%ADbrido%20V_1_0_0.md), [cierre y lecciones aprendidas](docs/03%20Implementaci%C3%B3n/Sprint%204/11%20Cierre%20y%20lecciones%20aprendidas%20V_1_0_0.md) y [correspondencia con la consigna](docs/03%20Implementaci%C3%B3n/Sprint%204/CONTROL_SEMANA14.md).

**Estado de CI/CD:** tres workflows preparados y validados localmente, sin ejecución remota. La web ya está publicada manualmente en Wasmer con Neon; falta adaptar y ejecutar CD automático. [Configuración y puertas de despliegue](docs/03%20Implementaci%C3%B3n/Sprint%204/12%20Automatizaci%C3%B3n%20CI-CD%20V_1_0_0.md). No se publica en esta tarea.


## Verificación complementaria de Semana 14 — 18/11/2026

Se corrigió la consulta repetida de coordenadas en la matriz vial y el caso OSRM 1×1. Resultado: 145 pruebas backend y 30 E2E en Chromium, Firefox y WebKit aprobadas; cobertura combinada backend 2882/3200 ≈ 90.0625 %. Se conserva el corte Flutter del 17/11 con 103 aprobadas. La campaña ampliada verifica 15 escenarios después de la deduplicación; el fallo frío anterior se conserva.

- [Resultados y límites](docs/03%20Implementaci%C3%B3n/evidencias/20261118-semana14/RESULTADOS.md), [Playwright HTML](docs/03%20Implementaci%C3%B3n/evidencias/20261118-semana14/playwright-html/index.html), [matriz E2E](docs/03%20Implementaci%C3%B3n/evidencias/20261118-semana14/MATRIZ_E2E.md) y [cobertura HTML](docs/03%20Implementaci%C3%B3n/evidencias/20261118-semana14/htmlcov/index.html).
- [Encuesta SUS anónima](docs/03%20Implementaci%C3%B3n/Sprint%204/instrumentos/Encuesta_SUS.html): lista para aplicar; sin respuestas reales ni puntuación inventada. [Aplicación y cálculo](tools/sus/README.md).
- [CI](.github/workflows/ci.yml), [pruebas](.github/workflows/tests.yml) y [producción](.github/workflows/deploy-production.yml): preparados localmente. Al corte local del 18/11 no se habían ejecutado ni elegido proveedor. El 19/11 se publicó manualmente en Wasmer con Neon; el workflow VPS continúa deshabilitado hasta adaptarlo a esa plataforma y autorizar su ejecución.

Los badges siguientes consultan el estado remoto al publicarse; en este corte no acreditan una ejecución:

[![CI](https://github.com/DartBlackLink/PFA/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/DartBlackLink/PFA/actions/workflows/ci.yml)
[![Pruebas](https://github.com/DartBlackLink/PFA/actions/workflows/tests.yml/badge.svg?branch=main)](https://github.com/DartBlackLink/PFA/actions/workflows/tests.yml)
[![Producción](https://github.com/DartBlackLink/PFA/actions/workflows/deploy-production.yml/badge.svg?branch=main)](https://github.com/DartBlackLink/PFA/actions/workflows/deploy-production.yml)

El [control de Semana 14](docs/03%20Implementaci%C3%B3n/Sprint%204/CONTROL_SEMANA14.md) separa lo verificado de lo que requiere usuarios reales, publicación autorizada y despliegue público. No se declara cierre formal del sprint.


## Actualización de publicación — 19/11/2026

La [web pública de EcoLogística Huancayo](https://ecologistica-huancayo-web.wasmer.app/) y FastAPI en Wasmer están conectados con Neon. Se comprobaron 41 operaciones/contratos API y 12 comprobaciones de Chromium; el repartidor confirmó por UI la recepción v2 y la última entrega. La persistencia se contrastó directamente en PostgreSQL. [Evidencias y límites](docs/03%20Implementaci%C3%B3n/evidencias/20261119-despliegue-publico/RESULTADOS.md).

Este corte sustituye la ausencia de URL/proveedor indicada al 18/11; los resultados históricos conservan su fecha. No se publicaron cambios en GitHub ni se ejecutó Actions. El workflow preparado para VPS requiere adaptarse a Wasmer y comprobarse; la carga actual fue manual. SUS sigue sin respuestas reales y la aceptación formal continúa por realizar. No se declaran aprobados esos requisitos por disponer de URL.
