# Matriz de consignas y prácticas — corte 30/10/2026

Se examinaron los dos ZIP aportados, las cuatro plantillas Markdown, el caso oficial y las 22 páginas del PDF de fase 1. Los proyectos MERN anidados se inventariaron, no se ejecutaron. “Nueva carpeta.zip” se menciona en el contexto, pero no fue adjuntada en esta entrega; no se presume su contenido.

| Fuente / requisito | Aplicación a EcoLogística | Evidencia / estado |
|---|---|---|
| Observación docente: conservar S1/S2 | Cuatro archivos propios por sprint; originales en Histórico y commit 66f25c8 | VERIFICADO; enlaces locales revisados |
| Plantilla: estado de un solo sprint | Alcance, cronograma, costos, calidad, riesgos, próximos avances y notas por carpeta | VERIFICADO documental; costos o ceremonias no se inventan |
| Plantilla: impedimentos | Solo detenciones acreditadas; no tareas ni riesgos potenciales | VERIFICADO documental; tablas sin incidentes ficticios |
| Observación: GOLD/feliz/infeliz/borde | BDD con resultado esperado, caso y evidencia; concurrencia y límites | VERIFICADO en S1/S2 y en incremento técnico S3 |
| Observación: retrospectiva | Problema, causa, corrección, prevención, responsable, fecha e indicador | VERIFICADO documental; propuestas de acuerdo diferenciadas |
| Caso oficial RF-03 | GA capacitado con ventanas, restricciones, parámetros y persistencia | VERIFICADO técnicamente; aceptación de EHAPP-13 requiere Jira |
| TP_2 16, semana 11 | Inspección 03/Sprint 03, SonarQube, WCAG y OWASP | Sonar backend VERIFICADO, gate OK y cobertura 91,4 %; revisión integral WCAG/OWASP PARCIAL |
| TP_2 16, semana 13 | Green Software y estándares, Inspección 04 | Informes técnicos preparados como apoyo; no se declara una entrega futura aceptada |
| TP_2 16, semanas 14/16 | Sprint 04, Playwright, CI/CD, usabilidad y final | No se adjudican a S3 ni se inventan pipelines/encuestas |
| Fase 1, páginas 3–13 | docs/01 Inicio, artefactos versionados, RF/RNF, BDD, datos, C4 y restricciones | Estructura existente conservada. Este incremento no certifica por sí solo toda la fase inicial; revisar consistencia de IDs con la matriz de reconciliación |
| Fase 1, páginas 14–21 | docs/02 Planificación, transformación, Jira, riesgos, presupuesto y navegación | Cuatro artefactos conservados; ID/calendario discrepantes señalados. Evidencia Jira actual PENDIENTE |
| Fase 1, DoD | Cobertura >80 %, análisis estático, revisión, pruebas y API documentada | Backend 91,39 % local / 91,4 % Sonar, gate OK, OpenAPI y suites; revisión independiente requiere evidencia |
| ISO/IEC 25010 | Escenarios de funcionalidad, fiabilidad, seguridad, rendimiento y usabilidad | Evidencia concreta de pruebas; no certificación ISO ni porcentaje de cumplimiento global |
| OWASP Top 10 | Roles en API, errores controlados, consultas SQLAlchemy, límites, JWT y secretos fuera del cliente | Tests de seguridad y controles del código; no pentest completo |
| WCAG/W3C y guía de accesibilidad | Semántica, etiquetas, mensajes, temas, contraste y distribución adaptable | Tests UI y revisión técnica; completar teclado/lector/criterios manuales |
| Nielsen/SUS | Inspección del flujo con diez heurísticas; instrumentos separados de participantes | Inspección técnica identificada. Sin puntajes SUS ni evaluadores inventados |
| HTML ambiental / Green engineering / Green JavaScript | Carga SQL por lotes, caché vial acotada, límite de cálculo y construcción bajo demanda | Mediciones de consultas y benchmark propios; sin cifras de MERN ni CO₂ digital ficticio |
| TP_2 15 | Ciclo de vida, soporte/configuración, procesos y documentación de pruebas | Prácticas de ISO 12207/29119 aplicadas; ISO 15504/CMMI solo referencias de clase, sin nivel de madurez atribuido |

## Adaptación y límites

El ejemplo Express/React/MongoDB y CO2.js se traduce en prácticas compatibles con FastAPI/Flutter/PostgreSQL. No se agrega un panel público de métricas ni un middleware Node a un backend Python solo porque aparezcan en el ejemplo. La huella digital requiere límites del sistema y factores documentados; el CO₂ del transporte se estima por vehículo y no representa emisiones digitales.

Referencias técnicas: [WCAG 2.1, W3C](https://www.w3.org/TR/WCAG21/), [medición en Green Software Foundation](https://learn.greensoftware.foundation/measurement/), [API OSRM](https://project-osrm.org/docs/v26.4.0/http/). La aplicación de estas prácticas no equivale a certificación.
