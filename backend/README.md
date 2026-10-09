# API EcoLogística

## Arranque sin Compose

Instala PostgreSQL 16 y crea una base vacía y un usuario con permisos para crear sus tablas. Desde `backend`, crea un archivo local `.env` y configura DATABASE_URL, SECRET_KEY, ADMIN_EMAIL, ADMIN_PASSWORD, DRIVER_EMAIL, DRIVER_PASSWORD y CORS_ORIGINS. DATABASE_URL debe usar el formato `postgresql+psycopg://USUARIO:CLAVE@localhost:PUERTO/BASE`; CORS_ORIGINS debe incluir `http://localhost:8080,http://127.0.0.1:8080`. Ajusta el puerto al de tu PostgreSQL.

```powershell
python -m venv .venv
.\.venv\Scripts\python.exe -m pip install -r requirements.txt
.\.venv\Scripts\alembic.exe upgrade head
.\.venv\Scripts\uvicorn.exe app.main:app --host 127.0.0.1 --port 8000
```

Swagger: http://localhost:8000/docs. Alembic obtiene la conexión desde `.env`. El archivo Compose se conserva únicamente como herramienta local y no se distribuye en el repositorio.

## Contrato disponible

| Ruta bajo /api/v1 | Método | Acceso |
| --- | --- | --- |
| /health | GET | Público |
| /auth/login | POST formulario username/password | Público; 401 por credenciales, 429 con Retry-After durante bloqueo |
| /auth/me | GET | Usuario activo autenticado |
| /vehicles/ | GET, POST | ADMIN |
| /vehicles/{id} | PUT | ADMIN |
| /drivers/ | GET, POST | ADMIN |
| /drivers/{id} | PUT | ADMIN |
| /drivers/me | GET | ADMIN o REPARTIDOR; consulta el perfil del usuario |
| /orders/ | GET, POST | ADMIN |
| /routes/ | GET | ADMIN ve registros; REPARTIDOR ve exclusivamente sus rutas |

Los listados admiten skip >= 0 y limit entre 1 y 1000. POST devuelve 201; los conflictos de placa, DNI/correo se informan con 409 y los campos inválidos con 422. Los esquemas y ejemplos completos se consultan en Swagger. No existe aún un endpoint de optimización ni exportación PDF.

El control de acceso guarda una clave HMAC por correo normalizado, intentos y vencimiento en PostgreSQL. El bloqueo se serializa por fila para evitar carreras. Fallos 3/4/5 generan 5/10/300 segundos; durante el plazo no se incrementa ni extiende el bloqueo. Un acceso correcto después del plazo reinicia el contador. Los datos del usuario activo y su rol se comprueban en cada petición protegida.

## Pruebas aisladas

El siguiente procedimiento de pruebas usa el entorno Docker local existente (contenedor PostgreSQL `ecologistica-postgres` y red `ecologistica_default`); esos recursos no se crean al clonar el repositorio. Con ese entorno encendido, crea exclusivamente esta base temporal y un contenedor de pruebas:

```powershell
docker exec ecologistica-postgres createdb -U ecologistica ecologistica_revision_20261007
docker build -t ecologistica-backend:qa ./backend
docker run -d --name ecologistica-qa --network ecologistica_default -e DATABASE_URL=postgresql+psycopg://ecologistica:ecologistica@postgres:5432/ecologistica_revision_20261007 -e ROUTING_BASE_URL=http://127.0.0.1:8090/route/v1/driving ecologistica-backend:qa
# Espera a que los logs indiquen Application startup complete.
docker logs ecologistica-qa
docker cp backend/tests/test_integration.py ecologistica-qa:/tmp/test_integration.py
docker exec -e PYTHONPATH=/app ecologistica-qa python /tmp/test_integration.py
```

La suite tiene nueve casos y crea datos ficticios en esa base temporal. Simula el vencimiento del bloqueo modificando exclusivamente el plazo de identidades de prueba; no espera cinco minutos reales. El nombre de red corresponde a el proyecto local ecologistica. Limpieza exclusivamente de esos recursos:

```powershell
docker rm -f ecologistica-qa
docker exec ecologistica-postgres dropdb -U ecologistica ecologistica_revision_20261007
docker image rm ecologistica-backend:qa
```

La migración 0002 añade controles sin eliminar datos históricos. Algunos CHECK se crean NOT VALID para preservar registros anteriores: audita y corrige dichos registros antes de validar esas restricciones sobre toda la tabla.

## Asignaciones y mapa

POST /api/v1/routes/ (ADMIN): vehiculo_id, repartidor_id y pedidos (lista ordenada de 1 a 20 IDs). GET /api/v1/routes/{id} devuelve geometría vial, origen y detalles, con control de propietario. POST /orders/ admite latitud, longitud y punto_referencia. Los pedidos asignados pasan a ASIGNADO. Configuración: ROUTING_BASE_URL, por defecto proveedor OSRM de demostración. Se agregó la migración 0003_route_geometry. La suite de integración ahora contiene nueve casos; el último inicia un proveedor HTTP de prueba local en 8090, por lo que el contenedor QA debe configurarse con ROUTING_BASE_URL=http://127.0.0.1:8090/route/v1/driving para ejecutar ese caso.




## Disponibilidad al asignar (US-004)

POST /api/v1/routes/ exige inicio_planificado (ISO 8601 con zona, por ejemplo 2026-10-10T09:00:00-05:00) y admite servicio_min_por_entrega (0–120; inicial 5). La API calcula fin_planificado = salida + tiempo vial + número de entregas × atención. Rechaza 422 fuera del turno y 409 por cruce del repartidor/vehículo o ruta antigua sin horario; la transacción conserva los pedidos. PUT /api/v1/routes/{id}/horario (ADMIN) regulariza o cambia horarios de rutas PLANIFICADAS con los mismos controles. Los intervalos contiguos se permiten. Aplicar Alembic hasta 0004_route_schedule. Caso 09 verifica disponibilidad, concurrencia y regularización en base aislada.
