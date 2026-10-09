# Base de datos PostgreSQL 16

`schema.sql` contiene únicamente la estructura SQL generada con Alembic hasta `0004_route_schedule`, incluyendo el historial de versiones. No contiene registros, hashes de contraseñas ni respaldos del equipo.

La fuente de verdad son las migraciones en `../backend/migrations/versions`. No se duplican esas migraciones aquí.

## Instalación recomendada

Instala PostgreSQL 16, crea una base vacía y configura `backend/.env` con DATABASE_URL. Sigue los comandos del [backend](../backend/README.md) para instalar dependencias, ejecutar `alembic upgrade head` e iniciar la API. Al arrancar, el backend crea las cuentas configuradas si no existen. La base nueva no contiene vehículos, perfiles de repartidor, pedidos ni rutas: registrarlos desde la web.

## Alternativa con SQL

Para una base vacía fuera de Compose: `psql -U USUARIO -d BASE -f database/schema.sql`. No ejecutar sobre una base existente. Como el archivo registra `alembic_version`, el backend reconocerá las migraciones ya aplicadas. Utiliza Alembic para futuras actualizaciones; no vuelvas a importar el esquema.

Los CHECK creados NOT VALID preservan compatibilidad con datos históricos. Antes de validar una base histórica, corregir sus registros según el informe técnico.

## Corte de demostración — 09/10/2026

Las cuatro migraciones del backend siguen siendo la fuente de la estructura actual; la migración 0004 añade horarios planificados; la carga de demostración no altera el esquema. La base local utilizada por la aplicación conserva sus datos: 7 vehículos, 8 repartidores, 22 pedidos y 21 rutas. Copiar fuentes no traslada ni reemplaza PostgreSQL. El repositorio distribuye el esquema reproducible, sin dump de cuentas, tokens o contraseñas. [Detalle del conjunto ficticio](../docs/03%20Implementaci%C3%B3n/evidencias/DATOS_DE_PRUEBA_20261009.md).
