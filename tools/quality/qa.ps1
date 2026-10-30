$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$runId = [guid]::NewGuid().ToString('N').Substring(0, 10)
$qaNetwork = "ecologistica-quality-$runId"
$qaDatabase = "ecologistica-quality-db-$runId"
$qaEnvFile = Join-Path ([System.IO.Path]::GetTempPath()) "ecologistica-quality-$runId.env"
$createdNetwork = $false
$createdDatabase = $false

function Assert-Command([string]$operation) {
    if ($LASTEXITCODE -ne 0) { throw "Falló: $operation" }
}

Push-Location -LiteralPath $projectRoot
try {
    $null = New-Item -ItemType Directory -Path (Join-Path $projectRoot 'reports') -Force
    docker build -f tools/quality/Dockerfile -t ecologistica-quality:local .
    Assert-Command 'construcción QA'
    $qaKey = [Convert]::ToHexString([Security.Cryptography.RandomNumberGenerator]::GetBytes(48))
    @(
        'DATABASE_URL=postgresql+psycopg://qa:qa-isolated-tests@postgres-qa:5432/ecologistica_revision_20261007'
        "SECRET_KEY=$qaKey"
        'ALLOW_LOCAL_PROVIDER_URLS=true'
        'ROUTING_BASE_URL=http://127.0.0.1:8090/route/v1/driving'
        'BOOTSTRAP_DEMO_USERS=false'
    ) | Set-Content -LiteralPath $qaEnvFile -Encoding ascii
    docker network create --label ecologistica.purpose=quality-audit $qaNetwork
    Assert-Command 'red QA'
    $createdNetwork = $true
    docker run -d --name $qaDatabase --network $qaNetwork --network-alias postgres-qa --label ecologistica.purpose=quality-audit --tmpfs /var/lib/postgresql/data -e POSTGRES_USER=qa -e POSTGRES_PASSWORD=qa-isolated-tests -e POSTGRES_DB=ecologistica_revision_20261007 postgres:16-alpine
    Assert-Command 'PostgreSQL temporal'
    $createdDatabase = $true
    $ready = $false
    for ($attempt = 0; $attempt -lt 20; $attempt++) {
        docker exec $qaDatabase pg_isready -U qa -d ecologistica_revision_20261007 *> $null
        if ($LASTEXITCODE -eq 0) { $ready = $true; break }
        Start-Sleep -Seconds 1
    }
    if (-not $ready) { throw 'PostgreSQL QA no está disponible' }
    docker run --rm --network $qaNetwork --env-file $qaEnvFile --mount "type=bind,source=$projectRoot,target=/workspace" ecologistica-quality:local sh -c 'ruff check backend/app --select E9,F63,F7,F82,F401,I && bandit -r backend/app -f json -o reports/bandit.json && pip-audit -r backend/requirements.lock.txt --format json --output reports/dependencies.json && python -m pytest backend/tests --cov --cov-config=tools/quality/coverage.ini --cov-report=term-missing --cov-report=xml:reports/coverage.xml --junitxml=reports/test-results.xml -q'
    Assert-Command 'análisis y pruebas'
    Write-Host 'Calidad local aprobada. Informes en reports/. Importa la cobertura en SonarQube siguiendo tools/quality/README.md.'
} finally {
    # Solo recursos temporales creados por esta ejecución; nunca los contenedores de la app.
    if ($createdDatabase) { docker rm -f $qaDatabase *> $null }
    if ($createdNetwork) { docker network rm $qaNetwork *> $null }
    if (Test-Path -LiteralPath $qaEnvFile) { Remove-Item -LiteralPath $qaEnvFile }
    Pop-Location
}
