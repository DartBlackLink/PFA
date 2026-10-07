[⌂ README principal](../../README.md) | [Registro de revisión](../../REVISION_DOCUMENTAL.md) | [Guía de ajustes](../../GUIA_DE_AJUSTES_Y_CIERRE.md) | [← Anterior](02%20Artefactos%20Jira%20V_1_1_0.md) | [Siguiente →](04%20Presupuesto%20del%20proyecto%20V_1_1_0.md)

# Registro de riesgos

| Campo | Valor |
| --- | --- |
| Proyecto | EcoLogística Huancayo - DistriRápido S.A.C. |
| Responsable | Jordy Steve Chancasanampa Torres |
| Modalidad | Individual; responsabilidades Scrum adaptadas |
| Fecha de revisión | 07/10/2026 |
| Versión documental | 1.1.0 |
| Estado | Especificación y plan de trabajo; validación según criterios de aceptación |

## Método y escala

Severidad=Probabilidad(1-5)×Impacto(1-5). Baja: 1-6; Media: 7-14; Alta: 15-25. Los rangos cubren toda la escala, incluso valores no obtenibles por el producto de enteros. P expresa exposición estimada, no frecuencia medida. Revisión al 07/10/2026; propietario de todos los riesgos: Jordy Steve Chancasanampa Torres.

| ID | Riesgo | Categoría | P | I | P×I | Mitigación preventiva | Contingencia | Estado/evidencia | Hito de revisión |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| RSK-01 | Motor supera 45 s | Técnica | 4 | 5 | 20 Alta | Dataset y profiling desde prueba temprana | Ajustar población, reparación y presupuesto de evaluación | Abierto; sin benchmark | Antes de aprobar US-007 |
| RSK-02 | Proveedor de tráfico inaccesible | Integración | 3 | 4 | 12 Media | Verificar acceso, cuotas y adaptador | Carga manual fechada; declarar ausencia de tiempo real | Abierto; validar acceso/alternativa manual | Antes de integrar RF-03 |
| RSK-03 | Pedidos sin coordenadas/campos | Datos | 4 | 4 | 16 Alta | Campos obligatorios y estado BORRADOR | Excluir con causa; completar ubicación | Brecha observada en contrato actual | Antes de planificación de rutas |
| RSK-04 | Capacidad individual insuficiente | Gestión | 5 | 4 | 20 Alta | Refinar 13 SP y limitar WIP | Replanificar complementarios preservando núcleo | Abierto; velocidad no medida | Cada Sprint Planning |
| RSK-05 | Vulnerabilidad crítica | Seguridad | 3 | 5 | 15 Alta | Escaneo, revisión y casos de abuso | Bloquear release y corregir con regresión | No se evaluó ejecución de seguridad | Antes del release |
| RSK-06 | Adaptación Flutter/modalidad no aceptada | Académica | 3 | 5 | 15 Alta | Presentar ADR-02 y adaptación individual | Ajustar cliente o modalidad según decisión docente | Abierto; presentar ADR-02 | Antes de implementación avanzada |
| RSK-07 | Mockups/canales insuficientes | UX | 3 | 3 | 9 Media | Checklist RF-campos-estados | Refinar formularios y área cliente | Parcial: imágenes disponibles | Antes de compromiso de historia UI |
| RSK-08 | Migración/esquema diverge | BD | 3 | 5 | 15 Alta | Operaciones explícitas y prueba upgrade | Restaurar respaldo y corregir evolución | Brecha observada: create_all y CHECK ausentes | Antes de persistencia con datos conservables |
| RSK-09 | Repartidor accede a rutas ajenas | Seguridad | 4 | 5 | 20 Alta | Filtrar propietario y cruzar identidades | Bloquear consulta hasta corregir | Brecha observada en listado de rutas | Antes de aprobar acceso repartidor |
| RSK-10 | Sprint y documentación no coinciden | Planificación | 4 | 4 | 16 Alta | Conciliar EHAPP/SCRUM, códigos, fechas y SP | Registrar alcance real y mover incompletos | Brecha observada en capturas | Antes del cierre Sprint 1/2 |
| RSK-11 | Reglas legales mal atribuidas | Normativa | 3 | 4 | 12 Media | Fuentes oficiales y políticas simuladas separadas | Desactivar regla no verificada para operación real | Atribución Ley 30224 corregida documentalmente | Antes de afirmar cumplimiento normativo |
| RSK-12 | Métricas de demo declaradas como resultados | Calidad | 4 | 4 | 16 Alta | Etiquetar datos, periodo y fórmula | Mostrar Sin datos/no calculable | Brecha observada en reporte actual | Antes de aprobar dashboard/PDF |

## Seguimiento y escalamiento

Antes de Planning revisar exposición y capacidad; durante ejecución registrar impedimentos reales separados de riesgos; en Review revisar efectos y evidencia; en retrospectiva asignar mejora. Cada actualización de riesgo agrega fecha, resultado, responsable y exposición residual. No se marca resuelto por haber redactado una mitigación. Las fechas de resolución y costos reales no se inventan.

Las brechas observadas son hallazgos de auditoría, no impedimentos retrospectivos atribuidos a fechas de sprint desconocidas. Se convertirán en trabajo real e informe de implementación cuando se confirme periodo, alcance y evidencia.

## Riesgo de acceso progresivo

Bloqueo solo visual o contador perdido al recargar permitiría evadir RN-023. Mitigación: estado compartido por identificador, transición atómica, API como autoridad y pruebas de dos dispositivos/concurrencia. Mantener mensaje genérico para reducir exposición de cuentas; después de 5 fallos conservar esperas de 300 s hasta éxito o recuperación validada. Responsable: Jordy; revisión: EN-003-S1.

## Historial de control de cambios

| Versión | Fecha | Responsable | Cambio |
|---|---|---|---|
| 1.0.0 | 27/09/2026 | Jordy Steve Chancasanampa Torres | Versión previa del repositorio; conservada en historial Git y respaldo de revisión. |
| 1.1.0 | 07/10/2026 | Jordy Steve Chancasanampa Torres | Refinamiento documental: requisitos verificables, trazabilidad, decisiones y estado real de evidencias. Calendario propuesto, RN-023 y guía de ajustes alineados. Sin modificación del software ni cierre de sprint. |

[⌂ README principal](../../README.md) | [Registro de revisión](../../REVISION_DOCUMENTAL.md) | [Guía de ajustes](../../GUIA_DE_AJUSTES_Y_CIERRE.md) | [← Anterior](02%20Artefactos%20Jira%20V_1_1_0.md) | [Siguiente →](04%20Presupuesto%20del%20proyecto%20V_1_1_0.md)
