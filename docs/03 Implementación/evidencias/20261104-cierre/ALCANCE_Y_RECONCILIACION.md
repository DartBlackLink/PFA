# Alcance y discrepancias resueltas para la lectura del Sprint 3

Consulta actual: 04/11/2026, sitio ecologistica.atlassian.net, solo lectura. El buscador semántico del conector devolvió 403; se pudo consultar directamente Jira por JQL y obtener las incidencias/campos de sprint. No se interpreta ese 403 como falta de acceso a todo Jira.

| Fuente | Contenido observado | Tratamiento de cierre |
|---|---|---|
| Jira EHAPP-13 | US-005, optimización genética, 13 SP, Sprint 37/Sprint 3, Tareas por hacer. Dos escenarios: factible e inviable. | Fuente actual para el compromiso S3. No se cambia el estado ni se suman historias históricas. |
| Jira Sprint 37 | future; 07–21/10/2026 a las 00:00 Perú. | Fechas administrativas observadas, diferentes del corte técnico 04/11. Deben ser revisadas por el responsable; no retrofechar ceremonias. |
| Planificación local V1.2 | S3 09–23/11 con 22 SP, APK/pedidos/clientes; GA US-007 en S4. | Baseline anterior, ya identificada en RECONCILIACION_20261030.md. Sus alias se citan como LEG-V1.2; no se borran ni se convierten automáticamente en compromiso actual. |
| Jira EHAPP-19 | US-008, reporte PDF básico, 5 SP, Tareas por hacer, sin campo Sprint asignado. | **No pertenece al S3 comprometido observado. No hay un sprint actual verificable al que asignarlo.** |
| Roadmap local anterior | LEG-V1.2/US-013 reporte PDF, S6; LEG-V1.2/US-008 mapa. | Explica por qué el mismo número US-008 tenía otro significado. S6 es objetivo histórico, no una asignación de Jira. |
| Consigna EcoLogística original, p.2 | RF-06 solicita PDF; RF-03 optimización y RNF-01 rendimiento de 150/15. | PDF sigue siendo requisito global; separar la aceptación incremental de la aceptación del producto completo. |
| TP_2 16, p.2 | Inspección 03/Sprint 03: SonarQube, accesibilidad y OWASP. | No omitirlos por haber aprobado las pruebas funcionales. Faltantes explícitos en la matriz actual. |
| Ámbito | Consigna original Lima; instrucción vigente de Jordy: Huancayo y alrededores aprobados. README actual ya identifica la adaptación. Algunos documentos iniciales conservan redacción Lima/demo. | Mantener Huancayo en implementación y evidencia. Señalar al docente la adaptación y la vigencia de esos apartados; no trasladar datos limeños al software ni afirmar autorización docente no registrada. |

La nueva lectura autenticada confirma lo que antes solo estaba reportado: US-005/EHAPP-13 es el único compromiso recuperado del Sprint 3. No renumerar retrospectivamente Sprints 1/2. La revisión formal debe utilizar claves EHAPP estables y esta distinción de baselines.

Fuentes locales: `D:\UC\Consignas de Evaluación\03 Implementación\Plantilla en Markdown`, dos consignas HTML S1/S2, `D:\UC\Proyectos\Consigna de proyecto “EcoLogística Lima.pdf`, materiales de clase TP_2 16 y los documentos locales de Inicio/Planificación. No se encontró una consigna HTML independiente titulada Sprint 3 en la carpeta revisada; se explicita el uso de las plantillas comunes y del cronograma docente, en lugar de inventarla.

Fuentes Jira: [US-005](https://ecologistica.atlassian.net/browse/EHAPP-13), [PDF](https://ecologistica.atlassian.net/browse/EHAPP-19). Exportación mínima sin perfiles de usuario en [jira-scope.json](jira-scope.json).
