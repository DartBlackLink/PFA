# Base de datos PostgreSQL 16

schema.sql contiene exclusivamente la estructura generada desde la cadena Alembic 0001–0005, con alembic_version. No incluye cuentas, hashes de contraseñas, pedidos, rutas ni respaldos locales. La fuente de verdad permanece en backend/migrations/versions.

Para una base nueva, crea base/usuario y configura backend/.env; sigue el [arranque del backend](../backend/README.md), instalando requirements.lock.txt y ejecutando alembic upgrade head. La creación de cuentas exige activación explícita y credenciales propias; no se incorpora una contraseña predeterminada.

Alternativa para una base vacía: `psql -U USUARIO -d BASE -f database/schema.sql`. No ejecutar sobre una base existente. Para actualizaciones posteriores usa Alembic.

## Incremento 0005

plan_optimizacion guarda propietario, estado PREVISUALIZADO/CONFIRMADO, solicitud, solución, creación, vencimiento y huella de datos. ruta.plan_optimizacion_id es opcional para conservar las rutas manuales e históricas. La secuencia y ETA siguen en ruta_detalle. El índice de plan permite consultar las rutas resultantes.

La confirmación usa una transacción y bloqueos: no duplica una propuesta ni asigna parcialmente pedidos cuando cambia un dato o falla una validación. Los escenarios de concurrencia usan PostgreSQL real en QA aislada.

Al comprobar el arranque del 30/10 se conservaron 8 vehículos, 8 repartidores, 23 pedidos y 21 rutas de desarrollo. Estos conteos describen la base local; no se distribuyen esos registros. La carpeta móvil se mantiene independiente y no acredita una APK validada.

[Resultados](../docs/03%20Implementaci%C3%B3n/evidencias/20261030/RESULTADOS.md).

## Esquema hasta 0006 — 02/11/2026

schema.sql contiene únicamente estructura de la base QA hasta 0006_route_operation. Incluye tiempos reales de ruta/entrega, autor de entrega y estado CANCELADO de propuesta. No contiene pedidos, usuarios ni contraseñas. El camino de actualización de bases existentes son las migraciones Alembic; no ejecutar schema.sql encima de una base existente. La base principal conserva su versión hasta el despliegue autorizado.

## Esquema hasta 0007 — ampliación operativa

schema.sql se actualiza a 0007_traffic_replanning e incluye únicamente estructura, no cuentas ni datos de negocio. politica_trafico conserva revisión/reglas; revision_ruta conserva snapshot, propuesta, motivo, autor/aprobación/acuse; notificacion y lectura_notificacion separan aviso de recepción de ruta. ruta.version_recibida=0 significa sin confirmación efectiva. No reimportar este SQL sobre una base existente: actualizar mediante Alembic, con respaldo y autorización de despliegue.
