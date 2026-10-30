# SonarQube — resultado del 30/10/2026

**Proyecto:** ecologisticas. **Finalización:** 30/10/2026 11:45:51 (Lima, UTC−05). **Estado de procesamiento:** SUCCESS. **Quality Gate:** OK / PASSED.

| Indicador | Resultado de SonarQube |
|---|---|
| Cobertura | 91,4 % |
| Bugs | 0 |
| Vulnerabilidades detectadas | 0 |
| Code smells | 0 |
| Security hotspots | 0 |
| Duplicación | 0,0 % |
| Seguridad / fiabilidad / mantenibilidad | A / A / A |
| Incidencias abiertas | 0 |

**Análisis:** `aaabf7bf-fe6c-43be-b38d-8e41ba8eb4e3`. **Tarea:** `9d781306-23ca-4ccd-ae74-599cb86d29a4`. [Abrir el proyecto local](http://localhost:9000/dashboard?id=ecologisticas). [Evidencia estructurada sin credenciales](sonar_resultado.json).

## Alcance y configuración verificados

SonarQube 26.10.0, scanner @sonar/scan 5.0.2; perfiles Python y Docker **Sonar way core**, según el registro del escáner. Se analizaron backend/app, backend/migrations y backend/Dockerfile, importando la cobertura y los resultados JUnit de las 94 pruebas aprobadas. Se verificó que los 38 archivos fuente del análisis coinciden con la aplicación de desarrollo. La revisión previa comprobó también la igualdad de fuentes entre desarrollo y PFA.

Exclusiones: cachés __pycache__ y entornos .venv. No se modificaron el Quality Gate ni las reglas para conseguir este resultado. La API devolvió estado OK con la lista conditions vacía en esta ejecución; no se atribuyen condiciones evaluadas que no fueron devueltas. El cumplimiento del objetivo de cobertura superior al 80 % se verifica mediante la métrica real 91,4 %, de forma independiente.

Sonar muestra la cobertura con un decimal; pytest informó 91,39 % con líneas/ramas. Son resultados compatibles con su redondeo y método de importación, no porcentajes de funcionalidades o notas del profesor.

## Límites y seguridad de la ejecución

El resultado pertenece al backend Python y Dockerfile. Flutter/Web conserva sus 58 pruebas y análisis Dart separados; no se atribuye una APK validada ni un análisis Sonar de Dart. La ausencia de hallazgos corresponde a este código, perfiles y fecha; no garantiza seguridad absoluta. El análisis de dependencias se verificó por separado con pip-audit.

El token se introdujo en una entrada oculta y se transmitió al escáner mediante una variable de entorno de ese proceso. No se incluyó en argumentos, código, archivos versionables ni este informe. Al haberse compartido en el chat, su revocación posterior corresponde al propietario de la cuenta.

## Corrección del destino del análisis

El intento inicial sobre ecologistica2 fue rechazado por autorización/destino. El responsable confirmó la clave ecologisticas y el análisis se ejecutó allí correctamente. La consulta del gate se verificó usando analysisId; no se reutiliza como resultado vigente el análisis histórico del 23/10.
