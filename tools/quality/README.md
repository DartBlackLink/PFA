# Calidad reproducible

Requisitos: Docker Desktop, PowerShell 7 y Flutter para la Web. Desde la raíz del repositorio:

```powershell
.\tools\quality\qa.cmd
cd apps/web
flutter pub get
flutter analyze
flutter test --coverage
flutter build web --release --dart-define=API_BASE_URL=http://127.0.0.1:8000/api/v1
```

El runner crea una red y PostgreSQL temporal sin puertos publicados, usa migraciones reales y elimina exclusivamente sus recursos al terminar. Ejecuta Ruff, Bandit, pip-audit y pytest con cobertura de líneas y ramas, mínimo 81 %. No usa la base de la aplicación ni requiere Compose. Los informes se guardan en reports/, ignorado en Git. El contexto de construcción admite únicamente requirements del backend.

## SonarQube

Con SonarQube ya activo, ejecuta el scanner desde la raíz del repositorio, con la propiedad `project.settings=tools/quality/sonar-project.properties`. Configura tu host local y espera el Quality Gate. Genera la cobertura de esta versión antes del análisis. Usa un token nuevo en SONAR_TOKEN solo durante ese proceso o un lanzador local con entrada oculta; no lo pongas en parámetros, archivos versionados o capturas. Ajusta la clave del proyecto solo si el administrador indica otra.

La configuración analiza Python/migraciones/Dockerfile; las pruebas Flutter se informan por separado. El porcentaje de cobertura no equivale a una nota global del proyecto. No se cambian el Quality Gate ni las exclusiones para esconder hallazgos.

Benchmark puro del motor: `python tools/quality/benchmark_genetic.py` desde la raíz. Usa 150 pedidos sintéticos y 15 equipos, verifica factibilidad y escribe métricas propias en reports/genetic-benchmark.json. No usa ni modifica la base de la aplicación.
