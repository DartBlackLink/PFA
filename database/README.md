# Base de datos PostgreSQL 16

`schema.sql` contiene únicamente la estructura SQL generada con Alembic hasta `0003_route_geometry`, incluyendo el historial de versiones. No contiene registros, hashes de contraseñas ni respaldos del equipo.

La fuente de verdad son las migraciones en `../backend/migrations/versions`. No se duplican esas migraciones aquí.

## Instalación recomendada

Desde la raíz del repositorio, configura `.env` y ejecuta `docker compose up -d --build`. El backend aplica `alembic upgrade head` automáticamente y crea las cuentas configuradas si no existen. La base nueva no contiene vehículos, perfiles de repartidor, pedidos ni rutas: registrarlos desde la web.

## Alternativa con SQL

Para una base vacía fuera de Compose: `psql -U USUARIO -d BASE -f database/schema.sql`. No ejecutar sobre una base existente. Como el archivo registra `alembic_version`, el backend reconocerá las migraciones ya aplicadas. Utiliza Alembic para futuras actualizaciones; no vuelvas a importar el esquema.

Los CHECK creados NOT VALID preservan compatibilidad con datos históricos. Antes de validar una base histórica, corregir sus registros según el informe técnico.
