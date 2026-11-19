# Controles auxiliares — 18/11/2026

- `python -m unittest discover -s tools/sus -p 'test_*.py' -v`: 10 aprobadas; muestras algebraicas descartadas, no participantes SUS.
- `actionlint -oneline .github/workflows/ci.yml .github/workflows/tests.yml .github/workflows/deploy-production.yml`: salida sin hallazgos, código 0, actionlint 1.7.12.
- `bash -n` sobre tools/ci/start-qa.sh, tools/ci/stop-qa.sh y tools/deploy/deploy-release.sh: código 0. Solo análisis de sintaxis, no despliegue.
- `npm audit --json`: cero vulnerabilidades conocidas; [resultado](npm-audit.json). No implica cero vulnerabilidades de todo el proyecto.
- Revisión de entrega: no se incluyen .env privados, dumps, firmas Android, node_modules o credenciales operativas. Escaneo por patrones de tokens, claves privadas y DSN autenticadas, incluidos adjuntos JSON base64 y ZIP incrustado de Playwright. La única coincidencia revisada es la variable `$qa_password` generada aleatoriamente para el runner, no una contraseña literal. Sin hallazgos sin resolver en los archivos seleccionados. No equivale a auditoría del historial público ni a garantía absoluta.
- Hashes de origen/destino comprobados antes de copiar; respaldo reversible de documentos modificados. No hubo commit, push o edición Jira.

[Resultados](RESULTADOS.md).
