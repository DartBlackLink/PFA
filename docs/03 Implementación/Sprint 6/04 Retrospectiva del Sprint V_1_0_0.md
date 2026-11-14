# Retrospectiva del Sprint 6

**Proyecto:** EcoLogística Huancayo. **Responsable:** Jordy Steve Chancasanampa Torres. **Corte técnico:** 14/11/2026, America/Lima. **Versión:** 1.0.0.

**Método:** análisis técnico de problemas, correcciones y pruebas del corte. No se inventa una reunión. Los compromisos preventivos siguientes quedan propuestos al responsable para su retrospectiva real.

## ¿Qué aprendimos?

Registrar un nombre en cada pedido no conserva una preferencia asociada al mismo cliente. Se agregó gestión de clientes y selección por cliente_id; se probó el rechazo de clientes inactivos y la asociación persistida. Una equivalencia sin factor/fuente sería arbitraria: se exige el conjunto completo y se muestran los supuestos.

## ¿Qué estamos haciendo bien?

Se conservaron datos e identidad visual, se verificaron los controles nuevos a 360 px en claro/oscuro y se mantuvieron baja lógica y reactivación. La configuración ambiental registra autor y fecha; no se incluyeron contraseñas en evidencias.

## ¿Qué podemos hacer mejor?

### Personas

Explicar que una equivalencia de combustión no es compensación efectivamente realizada. La fuente y la unidad deben acompañar al número, también en el PDF.

### Relaciones

Separar demostración técnica de aprobación académica. Preparar Jira y las evidencias para que el responsable pueda confirmar la distribución de los sprints sin alterar reuniones o fechas anteriores.

### Procesos

Al respaldar se detectó que POSTGRES_DB nombra una base heredada distinta de la usada por FastAPI. Antes de migrar se consultó la conexión activa y se respaldó ecologistica_operativa con huellas. Aprendizaje: verificar el destino real, no asumirlo por una variable de arranque.

### Herramientas

El navegador de 360 px mostró los campos y acciones con desplazamiento; los tests de widgets no sustituyeron esa inspección. Las pruebas de backend se ejecutaron en un esquema QA aislado y los respaldos/credenciales quedaron fuera de PFA.

### Acciones a realizar

| ID | Compromiso preventivo | Hito | Verificación |
|---|---|---|---|
| R6-A01 | Mantener la asociación cliente_id al editar un pedido | Antes de cambiar formularios de pedidos | El cliente no se duplica y su estado se valida en servidor. |
| R6-A02 | Exigir fuente, unidad y factor antes de presentar equivalencia | En cada cambio de parámetro | El dato ausente se muestra no disponible; no se atribuyen créditos ni captura real. |
| R6-A03 | Verificar base activa y permisos del respaldo antes de migrar | Antes de toda migración | Nombre real confirmado, archivo legible y huellas anteriores conservadas. |
| R6-A04 | Revisar teclado/lector y obtener aceptación real | Antes de cierre académico | Resultado documentado por criterio, sin declarar certificación por capturas. |

Responsable propuesto: Jordy. No se marcan compromisos como cumplidos solo por redactarlos. Vinculación: [evidencias y resultados](../evidencias/20261114-desarrollo-integral/RESULTADOS.md) y [acciones externas](../ACCIONES_EXTERNAS_Y_CIERRE_WEB.md).

[Índice](README.md)
