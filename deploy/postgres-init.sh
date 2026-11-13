#!/bin/sh
set -eu
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname postgres <<'EOSQL'
\getenv app_user APP_DB_USER
\getenv app_password APP_DB_PASSWORD
\getenv app_db APP_DB_NAME
SELECT format('CREATE ROLE %I LOGIN PASSWORD %L', :'app_user', :'app_password') WHERE NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname=:'app_user') \gexec
SELECT format('CREATE DATABASE %I OWNER %I', :'app_db', :'app_user') WHERE NOT EXISTS (SELECT 1 FROM pg_database WHERE datname=:'app_db') \gexec
EOSQL
