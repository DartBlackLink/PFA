[Índice de implementación](../README.md) · [README del proyecto](../../../README.md)

# Retrospectiva del Sprint 2

**Proyecto:** EcoLogística Huancayo — caso DistriRápido S.A.C.

**Responsable:** Jordy Steve Chancasanampa Torres. **Sprint:** 2. **Versión:** 1.1.0. **Revisión correctiva:** 30/10/2026.

Revisión individual basada en los documentos y defectos del incremento; las acciones se reformulan el 30/10/2026 por observación docente. No se atribuye esta fecha a una ceremonia histórica.

## ¿Qué aprendimos?

Un formulario válido debe guardar el dato en la columna correcta y permitir leerlo de nuevo. La gestión de datos, la asignación manual y la optimización genética son capacidades diferentes.

## ¿Qué estamos haciendo bien?

Se separaron los campos de flota y repartidor, se validó en servidor y se conservaron pruebas de duplicación, inactivación y permisos.

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
| MEJ-S2-01 | Los criterios no cubrían de forma consistente cuatro rutas | Se redactaban ejemplos positivos sin una matriz de escenarios | Agregar GOLD, FELIZ, INFELIZ y BORDE por capacidad | Revisar la matriz antes de aceptar una historia y enlazar prueba/evidencia | Jordy | 30/10/2026 | Cuatro rutas verificables por capacidad del sprint |
| MEJ-S2-02 | Las mejoras eran tareas genéricas sin prevención de recurrencia | La retrospectiva no vinculaba problema, causa y verificación | Registrar acción correctiva, prevención y resultado medible | Comprobar compromisos al preparar cada incremento | Jordy | 30/10/2026 | Cada acción tiene problema, causa, responsable, fecha e indicador |

**Seguimiento:** la corrección de redacción/estructura se verifica en esta revisión. La prevención se vuelve a comprobar en cada cierre; no se declara sostenida sin observar los siguientes incrementos.
