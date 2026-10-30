[Índice de implementación](../README.md) · [README del proyecto](../../../README.md)

# Retrospectiva del Sprint 1

**Proyecto:** EcoLogística Huancayo — caso DistriRápido S.A.C.

**Responsable:** Jordy Steve Chancasanampa Torres. **Sprint:** 1. **Versión:** 1.1.0. **Revisión correctiva:** 30/10/2026.

Revisión individual basada en los documentos y defectos del incremento; las acciones se reformulan el 30/10/2026 por observación docente. No se atribuye esta fecha a una ceremonia histórica.

## ¿Qué aprendimos?

La autenticación, la sesión y la autorización son controles distintos. El estado del bloqueo debe conservarse en servidor y la migración debe identificar su base de destino.

## ¿Qué estamos haciendo bien?

Se documentó la política 5/10/300 y la validación por capas; se conservan pruebas negativas y de concurrencia con datos de QA.

## ¿Qué podemos hacer mejor?

### Personas
Separar la ejecución de la verificación, aunque exista un único responsable; una capacidad se acepta por evidencia y no por percepción de avance.

### Relaciones
Registrar la observación real del profesor, la decisión y su resolución; no inventar participantes, encuestas ni feedback.

### Procesos
Controlar el alcance por sprint, revisar los cuatro tipos de escenario y comprobar que las acciones previenen la causa del problema.

### Herramientas
Usar Git para conservar el historial, enlaces verificables y pruebas reproducibles en una base aislada. Jira requiere reconciliación de códigos y no se actualiza automáticamente.

### Acciones a realizar — compromisos correctivos

| ID | Problema detectado | Causa raíz | Acción correctiva | Prevención de recurrencia | Responsable | Fecha objetivo de esta corrección | Indicador verificable |
|---|---|---|---|---|---|---|---|
| MEJ-S1-01 | Se mezclaron periodos e IDs de varios sprints | Se reutilizó un informe único sin control de alcance | Separar carpeta y cuatro artefactos por sprint | Verificar que el informe identifica un solo sprint y conservar la entrega original | Jordy | 30/10/2026 | Cada sprint tiene sus cuatro archivos y su propio periodo |
| MEJ-S1-02 | Se confundieron validaciones por realizar con impedimentos | No existía una definición operativa de bloqueo | Registrar solo bloqueos acreditados y clasificar el resto como riesgo/tarea/defecto | Revisar fecha, actividad detenida, impacto e intervención antes de crear un IMP | Jordy | 30/10/2026 | Cero filas IMP sin evidencia de bloqueo |

**Seguimiento:** la corrección de redacción/estructura se verifica en esta revisión. La prevención se vuelve a comprobar en cada cierre; no se declara sostenida sin observar los siguientes incrementos.
