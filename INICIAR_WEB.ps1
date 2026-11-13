param([switch]$Reconstruir)
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath $PSScriptRoot
if (-not (Test-Path -LiteralPath '.env')) {
    throw 'Falta la configuración privada .env. Consulta README.md; no uses credenciales demo.'
}
if ($Reconstruir) {
    Push-Location -LiteralPath 'apps/web'
    flutter pub get
    if ($LASTEXITCODE -ne 0) { throw 'Falló la resolución de Flutter.' }
    flutter build web --release --output build/web-final --dart-define=API_BASE_URL=http://127.0.0.1:8000/api/v1
    if ($LASTEXITCODE -ne 0) { throw 'Falló la compilación web.' }
    Pop-Location
    docker compose build api web
    if ($LASTEXITCODE -ne 0) { throw 'Falló la construcción de las imágenes.' }
}
docker compose up -d --no-recreate postgres api web
if ($LASTEXITCODE -ne 0) { throw 'No se pudo iniciar Compose. Revisa Docker Desktop y docker compose logs api web.' }
if ($Reconstruir) {
    docker compose up -d --no-deps api web
    if ($LASTEXITCODE -ne 0) { throw 'No se pudo aplicar la nueva imagen de api/web.' }
}
$listo = $false
for ($intento = 0; $intento -lt 45; $intento++) {
    try {
        $salud = Invoke-RestMethod 'http://127.0.0.1:8000/api/v1/health' -TimeoutSec 3
        $web = Invoke-WebRequest 'http://127.0.0.1:8080/healthz' -TimeoutSec 3
        if ($web.StatusCode -eq 200 -and $salud.status) { $listo = $true; break }
    } catch { Start-Sleep -Seconds 1 }
}
if (-not $listo) { throw 'Los servicios no respondieron a tiempo. Consulta docker compose ps y docker compose logs api web.' }
Write-Host 'Web: http://127.0.0.1:8080/#/login'
Write-Host 'API: http://127.0.0.1:8000/docs'
Write-Host 'Se conservan el volumen y la base de datos. Las claves son privadas.'
