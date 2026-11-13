# Sprint 4 — Mapa, indicadores y validación del rendimiento

**Proyecto:** EcoLogística Huancayo. **Responsable:** Jordy Steve Chancasanampa Torres. **Versión documental:** 1.0.2. **Fecha:** 13/11/2026.

Expediente documental preparatorio. El responsable aceptó el alcance sugerido: EHAPP-15/US-006, EHAPP-16/US-007 y EHAPP-14/EN-002, **15 SP propuestos**. Jira todavía no contiene un Sprint 4: no se atribuyen fechas oficiales, historias aceptadas ni una reunión de cierre. Esta intervención prepara documentos; no implementa funciones ni ejecuta pruebas nuevas del producto.

## Documentos

Se mantienen los cuatro archivos y títulos de las plantillas del profesor. Los anexos adaptan la organización del ejemplo a nuestros requisitos y tecnologías.

| Archivo | Finalidad |
|---|---|
| [01 Informe de estado](01%20Informe%20de%20estado%20del%20proyecto%20V_1_0_0.md) | Alcance exclusivo del Sprint 4, control, riesgos y próximos avances. |
| [02 Registro de impedimentos](02%20Registro%20de%20Impedimentos%20V_1_0_0.md) | Únicamente interrupciones reales de actividades comprometidas. |
| [03 Revisión](03%20Revisi%C3%B3n%20del%20Sprint%20V_1_0_0.md) | Criterios GOLD, felices, infelices y de borde; demostración y aceptación. |
| [04 Retrospectiva](04%20Retrospectiva%20del%20Sprint%20V_1_0_0.md) | Problemas de preparación, tratamiento y compromisos preventivos. |
| [05 Calidad de código](05%20Calidad%20de%20c%C3%B3digo%20V_1_0_0.md) | Cobertura y SonarQube: antecedentes y comprobación exigida a la nueva versión. |
| [06 Seguridad OWASP](06%20Seguridad%20OWASP%20V_1_0_0.md) | Riesgos aplicables, controles y evidencia por comprobar. |
| [07 Accesibilidad WCAG](07%20Accesibilidad%20WCAG%20V_1_0_0.md) | Evaluación prevista del mapa, indicadores y navegación. |
| [08 Trazabilidad y versionamiento](08%20Trazabilidad%20y%20versionamiento%20V_1_0_0.md) | Correspondencia Jira/RF/RNF, diferencias históricas y fuentes. |
| [09 Plan de rendimiento](09%20Plan%20de%20validaci%C3%B3n%20del%20rendimiento%20V_1_0_0.md) | Protocolo reproducible 150 pedidos/15 equipos y reoptimización. |
| [Acciones de cierre](ACCIONES_PARA_CERRAR_SPRINT4.md) | Qué completar en Jira, capturas, pruebas y revisión real. |
| [Evidencias](evidencias/README.md) | Consulta real de Jira y reglas para incorporar resultados propios. |

## Alcance acordado para preparar la documentación

| Clave vigente | Elemento | SP en backlog | Requisito |
|---|---|---:|---|
| [EHAPP-15](https://ecologistica.atlassian.net/browse/EHAPP-15) | US-006 — Visualizar rutas en mapa | 5 | RF-04 |
| [EHAPP-16](https://ecologistica.atlassian.net/browse/EHAPP-16) | US-007 — Consultar dashboard esencial | 5 | RF-05 |
| [EHAPP-14](https://ecologistica.atlassian.net/browse/EHAPP-14) | EN-002 — Rendimiento del motor | 5 | RNF-01 |
| **Total propuesto** | **2 historias de usuario + 1 enabler** | **15** | Sin SP aceptados atribuibles al Sprint 4 |

La generación genética EHAPP-13 sigue siendo antecedente del Sprint 3; no se vuelve a contar como entrega nueva. PDF/EHAPP-19, compensación/EHAPP-24 y APK release quedan fuera del alcance propuesto. Seguridad, calidad y accesibilidad son verificaciones transversales; no se añaden SP ni se asignan sus issues a este sprint sin decisión registrada.

Zona: Huancayo, El Tambo, Chilca y alrededores urbanos aprobados de Pilcomayo, San Agustín de Cajas, Huancán, Huayucachi y Sapallanga. Se conserva `America/Lima`. Los datos de prueba deben identificarse como sintéticos y ubicarse en puntos públicos válidos de esa zona.

## Green IT y estándares de ingeniería

Los dos informes existentes se actualizaron el 13/11/2026 a contenido **1.2.0**, conservando sus nombres y ubicación de entrega. Se sigue el orden de los dos informes concretos del GitHub de ejemplo: diagnóstico, ocho optimizaciones individuales, comparación, modelo ambiental, evidencias y versionamiento; ISO, GSF, WSG, guía por capa y matriz de correspondencia se adaptan a Flutter/FastAPI/PostgreSQL con resultados propios.

- [Informe de reducción del impacto ambiental](../reduccion%20del%20impacto%20ambiental/01%20Informe%20de%20reduccion%20del%20impacto%20ambiental%20V_1_0_0.md).
- [Estándares de ingeniería y guía de desarrollo verde](../reduccion%20del%20impacto%20ambiental/02%20Estandares%20Ingenier%C3%ADa%20de%20software%20V_1_0_0.md).

No se declara un ahorro de energía o CO₂ digital sin un ANTES/DESPUÉS comparable. La organización sigue la guía de clase y el ejemplo; los resultados y límites corresponden a EcoLogística Huancayo.

## Fuentes y adaptación

- Plantillas comunes de `D:\UC\Consignas de Evaluación\03 Implementación\Plantilla en Markdown` y consignas S1/S2. No se localizó una consigna independiente S4 en esa carpeta; los anexos no se atribuyen como una rúbrica nueva del profesor.
- [Jira consultado el 13/11](evidencias/consulta-jira-20261113.json): los sprints administrativos observados son 1, 2 y 3; las tres candidatas están sin sprint y en Tareas por hacer.
- [Ejemplo de Sprint 04](https://github.com/JulioNaupariC/EcoLog-stica-Lima/tree/main/docs/03%20Implementaci%C3%B3n/Sprint%2004): se tomó la organización de revisión, retrospectiva, calidad, seguridad, accesibilidad, benchmark e índice. No se trasladan sus personas, ECL, fechas, métricas, capturas o aceptación a EHAPP.
- [Reconciliación propia](../evidencias/20261104-cierre/ALCANCE_Y_RECONCILIACION.md): la planificación LEG-V1.2 y los identificadores actuales no son intercambiables.

[Volver a Implementación](../README.md) · [README principal](../../../README.md)
