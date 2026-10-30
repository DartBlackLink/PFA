# Verificación técnica — 30/10/2026

## Alcance y versión

Backend FastAPI/Python 3.12, SQLAlchemy, psycopg y PostgreSQL 16; Web Flutter/Dart. Base del repositorio: commit 66f25c8, rama local codex/sprint3-20261030. Los archivos fuente de backend y Web se conciliaron con la aplicación de desarrollo; el cliente móvil independiente se conserva y no acredita una APK probada.

## Resultados ejecutados

| Verificación | Resultado | Límite |
|---|---|---|
| pytest con PostgreSQL temporal y cadena Alembic | 94 aprobadas; upgrade/downgrade/reupgrade ejecutados | El proveedor se controla en las pruebas API para reproducibilidad |
| Cobertura backend | 91,39 % combinada con ramas; umbral local 81 % | No equivale al porcentaje de funcionalidades o a cobertura Flutter |
| Ruff | Sin hallazgos en E9,F63,F7,F82,F401,I | Selección explícita de reglas, no todos los analizadores existentes |
| Bandit | Cero hallazgos | Análisis estático, no garantía absoluta de seguridad |
| pip-audit | Cero vulnerabilidades conocidas en el lock analizado | Depende de la base de avisos disponible en la fecha |
| Flutter | 58 pruebas aprobadas; analizador sin incidencias | Incluye GOLD de optimización en 360/768/1440 px y ambos temas |
| Compilación Web release | Correcta; 40 archivos, sin .env ni claves privadas | No sustituye pruebas Android |
| Motor 150/15 | 150 entregas únicas; 15 rutas; 7.907,60 ms | Datos sintéticos, matriz euclídea y ventanas amplias; sin red ni SQL |
| OSRM real, consulta pública de ejemplo | Una matriz válida, 1 tramo, geometría de 42 puntos | Dos ubicaciones públicas; no ensayo de carga ni tráfico real |
| Arranque de aplicación local | health ok y Alembic 0005 | Datos preservados: 8 vehículos, 8 repartidores, 23 pedidos, 21 rutas al comprobar |
| Consulta de rutas | 4 SELECT para 1 ruta y también para 4 | Consulta y serialización sin autenticación; no mide energía ni latencia de producción |
| SonarQube ecologisticas | Gate OK, cobertura 91,4 %, 0 bugs/vulnerabilidades/code smells/hotspots e incidencias abiertas, duplicación 0,0 % | Backend Python/Docker, perfiles Sonar way core; condiciones del gate detalladas en el informe |

La suite emitió una advertencia de deprecación del TestClient de Starlette/httpx. Las pruebas no fallaron por ella; debe seguirse la compatibilidad del entorno antes de futuras actualizaciones.

## Artefactos

- [JUnit backend](test-results.xml), [cobertura backend](coverage.xml), [Bandit](bandit.json), [dependencias](dependencies.json).
- [Benchmark reproducible del motor](benchmark_genetic.json), [verificación del artefacto Web](verificacion_build.json).
- [Matriz académica](MATRIZ_DE_CUMPLIMIENTO.md), [inspección heurística](INSPECCION_UI.md), [acciones externas](ACCIONES_EXTERNAS.md).
- Fuentes y pruebas: [backend](../../../../backend/README.md), [cliente Web](../../../../apps/web/README.md).

## Decisiones del incremento

El motor usa hasta 150 pedidos y 15 pares únicos de conductor/vehículo. Evalúa capacidad, servicio dentro de ventanas, turno, trabajo diario, pausas y solapamientos. Semilla 42, población 24 y 40 generaciones son valores iniciales configurables, no resultados garantizados para todos los conjuntos. El límite temporal puede finalizar una búsqueda antes de completar todas las generaciones; se guarda lo efectivamente ejecutado. La ausencia de candidato se comunica como búsqueda sin solución encontrada, no como demostración matemática de imposibilidad.

La confirmación bloquea recursos/pedidos, comprueba la huella de datos y conserva atomicidad. La vista previa no cambia estados. El combustible es distancia/consumo y el CO₂ es distancia×factor del vehículo: estimaciones logísticas, distintas del impacto digital.

## Revisión visual Web

Formulario cargado desde la aplicación local con sesión administrativa y pedido ficticio: [tema claro](ui_claro.jpg) y [tema oscuro](ui_oscuro.jpg). Las capturas muestran la pantalla y sus recursos; no simulan una confirmación ni una aceptación docente.

## Reproducción desde el repositorio

El runner tools/quality/qa.ps1 se ejecutó también desde PFA: 94 pruebas aprobadas y 91,39 % de cobertura, con PostgreSQL temporal propio. No depende del Compose ni de la base de desarrollo.

## Método del motor

El cromosoma contiene dos permutaciones: pedidos y prioridad de equipos. El decodificador prueba inserciones al final de cada recorrido y conserva únicamente las que cumplen las restricciones. El ranking prioriza atender todos los pedidos antes de comparar la función objetivo; una solución parcial no se entrega como válida.

Para recorridos factibles, la función minimiza Σ(0,35×km/100 + 0,15×litros/10 + 0,35×kgCO₂/20 + 0,15×minutos/480). Los divisores son escalas de referencia de la versión GA_VRPTW_1, no conversiones físicas ni indicadores de ahorro. El tiempo incluye servicio, espera y descanso. Las ventanas son duras: una tardanza invalida la inserción, no se acepta pagando una penalidad.

Se conserva la semilla y el trabajo efectivamente realizado. La misma semilla reproduce las decisiones de muestreo; si se alcanza el plazo temporal en un punto distinto, pueden variar la cantidad de evaluaciones y el resultado. El benchmark puro puede repetirse con `python tools/quality/benchmark_genetic.py`; deja su propia salida en reports/.

## Control de entrega

Se comprobaron 280 enlaces locales sin roturas, los cuatro documentos de cada uno de los tres sprints y 78 fuentes Python/Dart iguales entre desarrollo y entrega. La revisión de archivos versionables no detectó el secreto de firma del servidor ni tokens Sonar; los archivos privados y auxiliares excluidos permanecen fuera de la entrega. Git diff --check pasó; los avisos de conversión LF/CRLF de Windows no son errores funcionales. No se realizó push ni merge.

## Análisis SonarQube ejecutado

[Resultado vigente y alcance](SONARQUBE.md): análisis aaabf7bf-fe6c-43be-b38d-8e41ba8eb4e3, finalizado 30/10/2026 11:45:51 (Lima, UTC−05). La cobertura Sonar 91,4 % supera el objetivo del 80 %. No se ejecutaron nuevas pruebas porque no se modificó código de la aplicación tras la cobertura verificada.
