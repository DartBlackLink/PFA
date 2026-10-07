# Preparación para GitHub — 07/10/2026

Se copiaron fuentes desde `D:\UC\App\ecologistica`; el original no se movió ni modificó. No se ejecutaron commits ni push.

```text
PFA/
  apps/
    web/       # Flutter Web, código y pruebas
    mobile/    # Base Flutter Android/iOS; APK pendiente
  backend/     # FastAPI, pruebas y migraciones Alembic
  database/    # Esquema SQL sin datos y guía
  docs/        # Documentos existentes de las tres fases
  docker-compose.yml
  .env.example
  .gitignore
```

## Uso de la copia

1. En la raíz: copiar `.env.example` a `.env` y completar contraseñas y una clave aleatoria. Generar SECRET_KEY con `python -c "import secrets; print(secrets.token_hex(32))"`.
2. Ejecutar `docker compose up -d --build` y revisar `http://localhost:8001/docs`.
3. Seguir `apps/web/README.md`; la copia usa Web 8081, API 8001 y PostgreSQL 5433 para no interferir con la aplicación original.
4. Registrar datos nuevos en esta base vacía. No se copiaron registros ni el volumen Docker del original. El backend crea las dos cuentas según la configuración; registrar el perfil del repartidor desde administración.
5. Seguir `apps/mobile/README.md` al continuar con la APK. Tener carpetas separadas no acredita el cierre del cliente móvil ni de los sprints.

La fuente backend mantiene sus valores de demostración del proyecto original; Compose exige variables locales que los reemplazan. No utilizar los valores por defecto para una publicación. Los clientes nunca deben almacenar SECRET_KEY o contraseñas del servidor.

## Antes de subir manualmente

Revisar `git status --short` y `git diff --stat`; confirmar que no aparecen `.env`, claves de firma, `local.properties`, dependencias, compilaciones ni respaldos con datos. Añadir las nuevas carpetas y documentación al mismo repositorio. No se modificó Jira ni las capturas históricas. El desarrollo activo sigue en D:\UC\App\ecologistica: esta es una copia de entrega, por lo que futuras mejoras deben sincronizarse antes de subir.

## Verificación de esta preparación

El manifiesto `MANIFIESTO_COPIA.json` compara SHA-256 de las fuentes copiadas con el original (backend y fuentes/plataformas de ambos clientes). El esquema se generó con `alembic upgrade head --sql`, sin ejecutar modificaciones en PostgreSQL. No se levantó otro stack ni se compiló una APK durante la preparación.
