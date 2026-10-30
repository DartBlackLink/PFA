[Índice de implementación](../README.md) · [README del proyecto](../../../README.md)

# Revisión del Sprint 2

**Proyecto:** EcoLogística Huancayo — caso DistriRápido S.A.C.

**Responsable:** Jordy Steve Chancasanampa Torres. **Sprint:** 2. **Versión:** 1.1.0. **Revisión correctiva:** 30/10/2026.

## Historias y capacidades del sprint

**Alcance revisado:** Flota — EHAPP-10 / US-002 según contexto actualizado; Repartidores — ID Jira por reconciliar; LEG-20261009/US-004; Pedidos — EHAPP-12 / US-004 según contexto actualizado. Los IDs reportados del Jira actual se distinguen de los códigos históricos; véase [Reconciliación de alcance y códigos](../evidencias/RECONCILIACION_20261030.md). La aceptación académica requiere el registro de decisión del docente o responsable, no una declaración automática de Done.

## Demostración del trabajo y criterios de aceptación

GOLD demuestra el flujo completo hasta la persistencia y lectura; FELIZ cubre una operación válida alternativa; INFELIZ comprueba rechazo controlado; BORDE comprueba límites y condiciones excepcionales. Los casos siguientes se expresan como Dado/Cuando/Entonces y se enlazan a pruebas existentes, sin simular reuniones con stakeholders.

### Flota — EHAPP-10 / US-002 según contexto actualizado

| Caso | Dado | Cuando | Entonces / resultado esperado |
|---|---|---|---|
| CA-S2-FLOTA-GOLD | ADMIN y placa nueva | registra un vehículo, consulta sus datos, lo edita y lo inactiva | los campos persistidos coinciden con la lectura y el registro queda inactivo sin perder su historial |
| CA-S2-FLOTA-FELIZ | Datos válidos y recurso disponible | edita consumo de un vehículo existente con datos válidos | la lectura posterior conserva la modificación |
| CA-S2-FLOTA-INFELIZ | placa repetida, capacidad cero o acceso REPARTIDOR | Se solicita la operación | 409/422/403 y ausencia de altas inválidas |
| CA-S2-FLOTA-BORDE | placa equivalente en minúsculas/espacios e importes en el límite admitido | Se ejecuta en el límite o con la condición excepcional | normalización consistente y rechazo de valores fuera de precisión |

**Pruebas identificadas:** [backend/tests/test_integration.py](../../../backend/tests/test_integration.py) — `test_04_vehicle_crud_validation`. La existencia del caso y el resultado ejecutado son evidencias distintas; la ejecución vigente se registra en el informe de verificación técnica con su fecha y entorno.

### Repartidores — ID Jira por reconciliar; LEG-20261009/US-004

| Caso | Dado | Cuando | Entonces / resultado esperado |
|---|---|---|---|
| CA-S2-CONDUCTORES-GOLD | ADMIN, DNI nuevo y cuenta de repartidor | registra perfil, consulta sus campos, edita contacto e inactiva la cuenta | DNI, licencia, contacto, turno y origen se conservan separados y una cuenta inactiva no accede |
| CA-S2-CONDUCTORES-FELIZ | Datos válidos y recurso disponible | corrige contacto y disponibilidad con un turno válido | se guardan los campos sin cambiar la identidad vinculada |
| CA-S2-CONDUCTORES-INFELIZ | DNI/correo repetido, turno invertido o usuario sin permiso | Se solicita la operación | 409/422/403 sin perfiles duplicados |
| CA-S2-CONDUCTORES-BORDE | coordenadas extremas, contraseña UTF-8 de más de 72 bytes e identidad ya vinculada | Se ejecuta en el límite o con la condición excepcional | se respetan límites y unicidad del perfil |

**Pruebas identificadas:** [backend/tests/test_integration.py](../../../backend/tests/test_integration.py) — `test_05_driver_fields_update_and_disable`. La existencia del caso y el resultado ejecutado son evidencias distintas; la ejecución vigente se registra en el informe de verificación técnica con su fecha y entorno.

### Pedidos — EHAPP-12 / US-004 según contexto actualizado

| Caso | Dado | Cuando | Entonces / resultado esperado |
|---|---|---|---|
| CA-S2-PEDIDOS-GOLD | ADMIN, cliente, ubicación confirmada y ventana válida | registra un pedido y vuelve a consultarlo | cliente, ubicación, peso, prioridad y ventana coinciden con la persistencia y queda PENDIENTE |
| CA-S2-PEDIDOS-FELIZ | Datos válidos y recurso disponible | registra una dirección con punto de referencia y fecha con zona horaria | la API conserva la referencia y normaliza el texto |
| CA-S2-PEDIDOS-INFELIZ | ventana invertida, cliente inexistente o coordenada inválida | Se solicita la operación | 422 sin crear pedidos inválidos |
| CA-S2-PEDIDOS-BORDE | coordenadas en límites, ventana de igual inicio/fin y peso máximo admitido | Se ejecuta en el límite o con la condición excepcional | se distinguen límites válidos y ventana de duración nula rechazada |

**Pruebas identificadas:** [backend/tests/test_integration.py](../../../backend/tests/test_integration.py) — `test_07_orders_validation_and_persistence; test_10_destination_validation_and_lookup_permissions`. La existencia del caso y el resultado ejecutado son evidencias distintas; la ejecución vigente se registra en el informe de verificación técnica con su fecha y entorno.

## Resultado y evidencia

[Evidencia técnica histórica](../evidencias/PRUEBAS_20261009.md) conserva los resultados originales. Los incrementos adicionales de asignación manual y mapas no se convierten en cumplimiento de optimización genética ni en pruebas de APK. Las demostraciones deben usar datos sintéticos identificados y comparar entrada, respuesta y lectura posterior.

## Pendientes de aceptación

Relacionar cada criterio con la ejecución actual y la decisión de aceptación; confirmar los códigos/fechas Jira y registrar feedback real cuando ocurra. La lista operativa de acciones está fuera de los documentos de cierre y no se presenta como impedimentos.
