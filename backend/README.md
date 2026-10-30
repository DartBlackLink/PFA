# API EcoLogística

FastAPI/Python 3.12, SQLAlchemy y PostgreSQL 16. Instala dependencias reproducibles desde requirements.lock.txt.

## Arranque local

Crea una base vacía y un usuario PostgreSQL. En backend/.env configura DATABASE_URL con formato `postgresql+psycopg://USUARIO:CLAVE@localhost:5432/BASE` y SECRET_KEY aleatorio de al menos 32 caracteres. No hay clave secreta incorporada en el código. CORS_ORIGINS admite por defecto localhost/127.0.0.1:8080.

```powershell
python -m venv .venv
.\.venv\Scripts\python.exe -m pip install -r requirements.lock.txt
.\.venv\Scripts\alembic.exe upgrade head
.\.venv\Scripts\uvicorn.exe app.main:app --host 127.0.0.1 --port 8000
```

Para una base nueva, activa BOOTSTRAP_DEMO_USERS=true solo de forma explícita y configura ADMIN_EMAIL, ADMIN_PASSWORD, DRIVER_EMAIL y DRIVER_PASSWORD con valores propios; el inicio crea únicamente cuentas inexistentes. Después desactiva esa opción. Las contraseñas existentes no se sobrescriben. Registrar el perfil de repartidor y vincular sus datos antes de asignarlo. No distribuir credenciales ni .env. Compose y los lanzadores particulares del equipo quedan locales por decisión del responsable.

Swagger/OpenAPI: http://127.0.0.1:8000/docs. Salud: GET /api/v1/health.

## Contrato bajo /api/v1

| Ruta | Operación y acceso |
|---|---|
| /auth/login, /auth/me | Login y validación de usuario activo; 3 fallos → 5 s, siguiente → 10 s, posteriores → 300 s. Retry-After y contador del cliente |
| /vehicles/, /vehicles/{id} | ADMIN: listar, registrar y editar/inactivar flota |
| /drivers/, /drivers/{id}, /drivers/me | Gestión ADMIN; perfil propio autenticado |
| /orders/ | ADMIN: listar/registrar pedidos; filtro estado=PENDIENTE o ASIGNADO |
| /routes/, /routes/{id} | ADMIN consulta/asigna; REPARTIDOR consulta solo sus rutas |
| /routes/{id}/horario | ADMIN: regularizar horario de ruta PLANIFICADA con controles de turno y cruces |
| /optimizations/preview | ADMIN: propuesta GA sin asignar, 201; pedidos 1–150 y equipos 1–15 únicos |
| /optimizations/, /optimizations/{id} | ADMIN: últimas propuestas y detalle persistido |
| /optimizations/{id}/confirm | ADMIN: confirmación atómica e idempotente; 409 si vence/cambian datos |

GET de recursos admite skip y limit acotados. OpenAPI es la referencia exacta de tipos/métodos, validaciones y respuestas. Los errores de campo retornan 422; los conflictos 409; proveedor no disponible 503; búsqueda concurrente 429. No se asignan pedidos parcialmente cuando falla un plan.

## Optimización y proveedores

Se seleccionan pares de repartidor/vehículo; el GA distribuye y ordena pedidos entre ellos. Valida capacidad, atención dentro de ventanas, turno, jornada, descanso y ocupaciones. No garantiza el óptimo global ni usa tráfico en tiempo real. Los parámetros operativos no certifican normas legales.

ROUTING_BASE_URL usa OSRM HTTPS público por defecto; la matriz table y el recorrido route se obtienen del mismo proveedor configurado. GEOCODING_BASE_URL usa Photon HTTPS. Para producción se debe contratar/evaluar capacidad y privacidad del proveedor. Los proveedores locales HTTP solo se admiten mediante configuración explícita destinada a QA.

La propuesta conserva parámetros/semilla y vence en 10 minutos; confirmar verifica datos actuales y guarda rutas, ETA, geometría y estimaciones. Combustible y CO₂ se estiman usando los factores registrados por vehículo.

## Migraciones y calidad

0001–0004 se conservan; 0005 añade planes y FK opcional en rutas. Usa Alembic para actualizar bases existentes; nunca reimportes schema.sql sobre una base con datos. Los CHECK históricos NOT VALID requieren auditoría de registros antes de validarlos globalmente.

[Runner reproducible de calidad](../tools/quality/README.md): crea PostgreSQL temporal, aplica/revierte migraciones, verifica Ruff/Bandit/dependencias y ejecuta pytest con cobertura. No sigue el procedimiento antiguo que usaba la base local de la aplicación.

[Resultados del incremento](../docs/03%20Implementaci%C3%B3n/evidencias/20261030/RESULTADOS.md) y [revisión S3](../docs/03%20Implementaci%C3%B3n/Sprint%203/03%20Revisi%C3%B3n%20del%20Sprint%20V_1_0_0.md).
