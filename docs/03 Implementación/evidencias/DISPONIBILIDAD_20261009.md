# Disponibilidad y replanificación — 09/10/2026

## Alcance vigente

US-002 (3 SP) se acepta en Sprint 3, por decisión de Jordy. S1 queda en 19 SP, S2 en 19 SP y S3 en 22 SP; el total no aumenta. El acceso Web/API compartido es avance técnico S1, no una aceptación de APK.

## Operación en la aplicación

1. ADMIN abre Rutas → Asignar pedidos. Elige equipo, fecha y hora de salida de Lima, atención por entrega y pedidos ordenados.
2. OSRM estima el tiempo vial. El fin planificado suma ese tiempo y la atención de cada parada (valor inicial editable: 5 min, rango 0–120).
3. La API exige que la ruta completa quede dentro del turno del repartidor. Inicio y fin se comparan en UTC−5; la base guarda instantes con zona horaria.
4. Rechaza con 409 los cruces de cualquier ruta activa del repartidor o vehículo. Los intervalos contiguos se permiten; no se ha impuesto un descanso mínimo entre rutas. Los bloqueos de fila serializan solicitudes concurrentes.
5. Un rechazo no crea rutas ni cambia pedidos a ASIGNADO. Recursos inactivos, turno incompleto y fechas sin zona horaria se rechazan.
6. ADMIN puede usar el botón de calendario en una ruta PLANIFICADA para registrar/cambiar horario. Repartidor consulta salida y fin en el detalle, sin poder modificarlos.

Las rutas antiguas conservan fechas de horario nulas; no se deducen de la fecha de creación ni de una ventana de pedido. Mientras el equipo tenga alguna ruta activa sin horario, una nueva asignación se bloquea. La regularización permite completar sucesivamente esos horarios, comprobando los ya registrados. No acredita disponibilidad integral hasta completar los horarios del equipo.

El cálculo estima ocupación desde el origen hasta la última entrega. No contempla retorno a base, tráfico en vivo, descansos obligatorios ni la factibilidad de todas las ventanas por tramo; esas ampliaciones corresponden a la planificación avanzada del producto.

## Evidencia de prueba

- 29 pruebas Flutter aprobadas en D:/UC/App/ecologistica: las 27 anteriores y 2 de edición/validación del horario y conversión de hora Lima a UTC.
- 9 pruebas API aisladas aprobadas en 9.854 s. Caso 09: salida antes del turno, fin fuera del turno, duración con atención, colisiones de repartidor/vehículo, límites contiguos, rechazo sin cambiar el pedido, permisos, regularización y dos pedidos distintos compitiendo simultáneamente por el mismo equipo.
- flutter analyze sin incidencias y flutter build web satisfactorio (61,0 s).
- Migración 0004_route_schedule aplicada sobre PostgreSQL respaldado: se conservan las 21 rutas anteriores. Las fuentes verificadas y el SQL generado se copiaron a PFA; no se copiaron dumps ni configuraciones privadas.

Suite: [API](../../../backend/tests/test_integration.py), [Flutter](../../../apps/web/test/route_schedule_test.dart), [log API](ui_20261009/pruebas_api.txt).

[README principal](../../../README.md)
