# EcoLogística Huancayo

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

Expediente preparatorio de mapa, dashboard y validación del rendimiento: dos historias de usuario y un enabler, 15 SP propuestos. El alcance documental fue aceptado por el responsable; Jira todavía no tiene Sprint 4 creado. No se atribuyen implementación, pruebas nuevas o aceptación a este corte del 13/11/2026.

- [Documentos y anexos del Sprint 4](docs/03%20Implementaci%C3%B3n/Sprint%204/README.md).
- [Acciones de Jira, evidencias y cierre](docs/03%20Implementaci%C3%B3n/Sprint%204/ACCIONES_PARA_CERRAR_SPRINT4.md).
