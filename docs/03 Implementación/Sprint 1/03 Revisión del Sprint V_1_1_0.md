[Índice de implementación](../README.md) · [README del proyecto](../../../README.md)

# Revisión del Sprint 1

**Proyecto:** EcoLogística Huancayo — caso DistriRápido S.A.C.

**Responsable:** Jordy Steve Chancasanampa Torres. **Sprint:** 1. **Versión:** 1.1.0. **Revisión correctiva:** 30/10/2026.

## Historias y capacidades del sprint

**Alcance revisado:** Acceso, sesión y autorización API/Web. Los IDs reportados del Jira actual se distinguen de los códigos históricos; véase [Reconciliación de alcance y códigos](../evidencias/RECONCILIACION_20261030.md). La aceptación académica requiere el registro de decisión del docente o responsable, no una declaración automática de Done.

## Demostración del trabajo y criterios de aceptación

GOLD demuestra el flujo completo hasta la persistencia y lectura; FELIZ cubre una operación válida alternativa; INFELIZ comprueba rechazo controlado; BORDE comprueba límites y condiciones excepcionales. Los casos siguientes se expresan como Dado/Cuando/Entonces y se enlazan a pruebas existentes, sin simular reuniones con stakeholders.

### Acceso, sesión y autorización API/Web

| Caso | Dado | Cuando | Entonces / resultado esperado |
|---|---|---|---|
| CA-S1-IDENTIDAD-GOLD | Credenciales válidas y cuentas activas | inicia sesión, consulta identidad y un recurso autorizado y cierra sesión | la API y la Web reconocen el rol; después del cierre no se conserva acceso protegido |
| CA-S1-IDENTIDAD-FELIZ | Datos válidos y recurso disponible | renueva la pantalla con sesión vigente | restaura identidad mediante /auth/me |
| CA-S1-IDENTIDAD-INFELIZ | contraseña inválida, token vencido o rol sin permiso | Se solicita la operación | 401/403 sin datos protegidos |
| CA-S1-IDENTIDAD-BORDE | fallos 3/4/5 y solicitudes simultáneas | Se ejecuta en el límite o con la condición excepcional | esperas de 5/10/300 segundos sin extenderlas durante el bloqueo |

**Pruebas identificadas:** [backend/tests/test_integration.py](../../../backend/tests/test_integration.py) — `test_01_login_delays_and_reset; test_02_unknown_identity_and_concurrency; test_03_session_expiry_and_rbac`. La existencia del caso y el resultado ejecutado son evidencias distintas; la ejecución vigente se registra en el informe de verificación técnica con su fecha y entorno.

## Resultado y evidencia

[Evidencia técnica histórica](../evidencias/PRUEBAS_20261009.md) conserva los resultados originales. Los incrementos adicionales de asignación manual y mapas no se convierten en cumplimiento de optimización genética ni en pruebas de APK. Las demostraciones deben usar datos sintéticos identificados y comparar entrada, respuesta y lectura posterior.

## Pendientes de aceptación

Relacionar cada criterio con la ejecución actual y la decisión de aceptación; confirmar los códigos/fechas Jira y registrar feedback real cuando ocurra. La lista operativa de acciones está fuera de los documentos de cierre y no se presenta como impedimentos.
