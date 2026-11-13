# EcoLogística Huancayo

Aplicación Flutter ADMIN/REPARTIDOR, FastAPI y PostgreSQL. Fuente activa única: esta carpeta. El repositorio PFA contiene copias de entrega de las plataformas, no servidores paralelos.

## Operación local consolidada — 04/11/2026

Con Docker Desktop iniciado, ejecuta `./INICIAR_WEB.ps1` en PowerShell. Sirve las imágenes ya construidas; no inicia otro servidor Flutter. Web: http://127.0.0.1:8080/#/login; API: http://127.0.0.1:8000/docs.

Compose `ecologistica` tiene tres servicios: `postgres`, `api`, `web`. El volumen `ecologistica_ecologistica_postgres_data` persiste la información. API y web llevan el código compilado en sus imágenes y no dependen de stage ni de carpetas temporales. `docker compose logs api web` muestra sus registros.

Para reconstruir con cambios de código: `./INICIAR_WEB.ps1 -Reconstruir`. Esto construye y aplica las imágenes de api/web, conservando postgres. Revisa el respaldo antes de actualizar. No recrear postgres como parte de una actualización del frontend.

## Base y acceso

La base operativa `ecologistica_operativa` comienza sin pedidos, rutas, vehículos ni repartidores. Solo contiene el administrador inicial. Todos los datos de demostración anteriores se conservan en la base archivada `ecologistica` y en un respaldo restaurado/verificado; no son registros reales. Las pruebas automatizadas usan otra base aislada.

Administrador: `admin@ecologistica.com`. La contraseña inicial privada se entrega localmente al responsable; no se publica en este repositorio. Las claves demo antiguas no corresponden a esta base. El administrador registra la flota y crea los perfiles/cuentas de repartidor con datos coherentes antes de asignar rutas.

`.env` contiene secretos de servidor y se excluye de Git y de las imágenes. No copiar su contenido a Flutter ni al repositorio. El cliente recibe únicamente la URL pública de API mediante `--dart-define`. No existe una configuración de producción por el solo hecho de ejecutar Docker.

## Alcance funcional y geográfico

Huancayo, El Tambo, Chilca y los alrededores urbanos aprobados: Pilcomayo, San Agustín de Cajas, Huancán, Huayucachi y Sapallanga. Zona horaria peruana `America/Lima`.

Pedidos con ubicación confirmada, gestión de flota y repartidores, optimización genética, asignaciones con restricciones, mapa vial OSM/OSRM, operación del repartidor, incidencias, propuesta y confirmación ADMIN de reoptimización y recepción explícita por el repartidor. Los factores de congestión son estimaciones históricas/configuradas; no representan tráfico en vivo. La disponibilidad externa de mapas/rutas puede afectar el cálculo y debe mostrarse como error recuperable.

## Evidencias y límites

Consolidación: 127 pruebas backend y 81 Flutter aprobadas; analizador Flutter sin incidencias. Cobertura combinada backend 90,88 % (2261/2410 líneas y 478/604 ramas). Reportes reales en `reports/consolidacion_20261104/coverage.xml`, `htmlcov/index.html` y `test-results.xml`. Esto no equivale a cobertura de todo Flutter ni a ausencia universal de fallos.

La APK debug normal se conserva en `build/apk/ecologistica-huancayo-debug.apk`, con API del emulador `http://10.0.2.2:8000/api/v1`. Las pruebas Android registradas antes de limpiar la base son históricas; no se debe atribuirles una nueva ejecución contra esta base. Teléfono físico, firma release y despliegue HTTPS requieren verificación/configuración específica.

No eliminar volúmenes con `down -v` ni ejecutar podas globales. Los recursos antiguos permanecen conservados hasta aprobar su plan de limpieza. La consolidación no publica en GitHub ni cambia Jira.

## Reproducción desde el repositorio

En la raíz de PFA, prepara .env privado a partir de .env.sample con claves únicas; DATABASE_URL debe coincidir con APP_DB_PASSWORD. El volumen externo debe existir: `docker volume create ecologistica_ecologistica_postgres_data`. Si ya existe un volumen con datos, no lo reinicialices: conserva sus credenciales y migra de forma controlada. La inicialización deploy/postgres-init.sh crea el rol/base operativa solo en un clúster nuevo. El ADMIN se provisiona de forma privada por el responsable; no se distribuye una cuenta demo. Ejecuta `./INICIAR_WEB.ps1 -Reconstruir` con Flutter y Docker disponibles.

## Instalación en un equipo nuevo

Requisitos: Python 3, Flutter en PATH y Docker Desktop/Compose. Con un volumen nuevo y sin .env previo:

1. `python tools/deploy/configurar_nueva_instalacion.py` genera claves privadas; no debe ejecutarse para sustituir las de un volumen existente.
2. `docker volume create ecologistica_ecologistica_postgres_data` crea el volumen externo si no existe. Nunca borres uno existente para hacer funcionar estas instrucciones.
3. `./INICIAR_WEB.ps1 -Reconstruir` compila el cliente y las imágenes e inicia postgres/api/web.
4. `python tools/deploy/crear_admin.py` crea el primer ADMIN solicitando la contraseña con entrada oculta. Se niega a modificar una base con usuarios. No distribuye cuentas ni contraseñas demo.

En el equipo ya consolidado .env, volumen y administrador existen: basta ejecutar INICIAR_WEB.ps1. Crear un repartidor desde el formulario ADMIN proporciona su perfil y acceso; no hay un repartidor operativo preinstalado con datos ficticios.
