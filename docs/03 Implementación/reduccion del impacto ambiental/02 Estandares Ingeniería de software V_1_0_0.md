[Índice de implementación](../README.md)

# Estándares de ingeniería de software aplicados

**Proyecto:** EcoLogística. **Responsable:** Jordy Steve Chancasanampa Torres. **Versión:** 1.0.0. **Fecha:** 30/10/2026.

| Referencia de clase | Práctica adoptada | Evidencia | Límite de la afirmación |
|---|---|---|---|
| ISO/IEC 12207, ciclo de vida | Requisitos, diseño, implementación, verificación y control de configuración relacionados | RF-03 → código GA/API → escenarios S3; migraciones y rama local | No certifica el proceso organizacional completo |
| ISO/IEC 25010, calidad del producto | Restricciones funcionales, seguridad, fiabilidad, eficiencia y usabilidad expresadas en escenarios | Matriz académica y resultados técnicos | Sin puntuación global de calidad inventada |
| ISO/IEC/IEEE 29119, pruebas | Condiciones, entradas, resultados esperados y evidencia ejecutada; técnicas de límites y pruebas negativas | GOLD/feliz/infeliz/borde, pytest/JUnit y Flutter | No se declara conformidad con todas las partes de la norma |
| ISO/IEC 15504 / CMMI | Seguimiento de causas, compromisos e indicadores | Retrospectiva y checkpoints | Referencia de mejora; no evaluación ni nivel de madurez certificado |
| OWASP Top 10 | Autorización real, validación, límites, manejo de excepciones y separación de secretos | Tests de seguridad, Bandit y revisión del artefacto | Sin pentest integral ni promesa de riesgo cero |
| WCAG/W3C | Etiquetas, semántica, contraste, mensajes y adaptación de componentes | Tests UI y revisión visual; acciones manuales identificadas | No se afirma conformidad AA integral sin revisar criterios y lector |
| Nielsen | Inspección del flujo y correcciones trazables | INSPECCION_UI.md | No equivale a encuesta ni prueba con usuarios |
| Green Software | Procesamiento acotado y consultas por lotes | Prueba SQL y benchmark del motor | Sin CO₂ digital medido ni cifras copiadas de MERN |

## Trazabilidad y mejora continua

Cada resultado se relaciona con una fecha y una versión. Los documentos S1 y S2 mantienen su historia; el informe S3 describe solo su incremento. Las decisiones de aceptación se distinguen de las pruebas técnicas. Las acciones preventivas tienen indicador para que la misma falla no reaparezca.

La [matriz de cumplimiento](../evidencias/20261030/MATRIZ_DE_CUMPLIMIENTO.md) diferencia entregas de semana 11, semana 13 y semanas posteriores según el cronograma de clase. El [Quality Gate de SonarQube del 30/10](../evidencias/20261030/SONARQUBE.md) está verificado en ecologisticas, con cobertura 91,4 %. No se atribuye al motor nuevo el gate histórico del 23/10.
