<#
.SYNOPSIS
  Diagnostico del entorno del alumno. Solo lee, no modifica nada.

.DESCRIPTION
  Ejecutar cuando algo no funciona y no sabes por que. Imprime un resumen
  del estado de git, remotos, tags, rama actual, variables de entorno
  necesarias y conectividad al servidor Ollama del centro.

  Si algo aparece en rojo, copia la salida completa y pegala en el Issue
  o correo al profesor. Es mucho mas util que un "no me funciona".

.EXAMPLE
  ./scripts/alumno/doctor.ps1
#>
[CmdletBinding()]
param()

$upstreamUrl = "https://github.com/ichueca/studymate-curso.git"
$upstreamOwner = "ichueca"
$ollamaUrl = "http://185.193.11.153:11434/api/tags"

$script:errors = 0
$script:warns  = 0

function Write-OK($msg)   { Write-Host "  [OK]    $msg" -ForegroundColor Green }
function Write-Warn($msg) { Write-Host "  [WARN]  $msg" -ForegroundColor Yellow; $script:warns++ }
function Write-Err($msg)  { Write-Host "  [ERROR] $msg" -ForegroundColor Red;    $script:errors++ }
function Write-Info($msg) { Write-Host "  [INFO]  $msg" -ForegroundColor DarkGray }

Write-Host ""
Write-Host "=== Diagnostico del alumno ===" -ForegroundColor Cyan
Write-Host ""

Write-Host "-- Herramientas --" -ForegroundColor Cyan
if (Get-Command "git" -ErrorAction SilentlyContinue) {
    Write-OK "git: $(git --version)"
} else { Write-Err "git no esta en PATH." }

if (Get-Command "java" -ErrorAction SilentlyContinue) {
    $javaVer = (java -version 2>&1 | Select-String "version" | Select-Object -First 1).ToString()
    if ($javaVer -match '"(\d+)') {
        $major = [int]$Matches[1]
        if ($major -ge 21) { Write-OK "java: version $major" }
        else { Write-Err "java: version $major (necesitas 21+)" }
    } else { Write-Warn "java instalado pero version no reconocida: $javaVer" }
} else { Write-Err "java no esta en PATH." }

if (Get-Command "mvn" -ErrorAction SilentlyContinue) {
    Write-OK "mvn en PATH."
} else { Write-Info "mvn no en PATH (OK si lanzas desde Spring Tools)." }

Write-Host ""
Write-Host "-- Repositorio --" -ForegroundColor Cyan
git rev-parse --git-dir 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Err "No estas dentro de un repo git. cd a tu clon de studymate-curso."
    Write-Host ""
    Write-Host "=== Resumen: $script:errors errores, $script:warns avisos ===" -ForegroundColor Red
    exit 1
}
Write-OK "Repo git detectado."

$originUrl = git remote get-url origin 2>$null
if (-not $originUrl) {
    Write-Err "No hay remoto 'origin'."
} elseif ($originUrl -match "/$upstreamOwner/studymate-curso(\.git)?$") {
    Write-Err "origin apunta al UPSTREAM ($originUrl). Deberia ser TU fork."
} else {
    Write-OK "origin: $originUrl"
}

$upstreamCurrent = git remote get-url upstream 2>$null
if (-not $upstreamCurrent) {
    Write-Err "Falta remoto 'upstream'. Ejecuta scripts/alumno/setup.ps1."
} elseif ($upstreamCurrent -ne $upstreamUrl) {
    Write-Warn "upstream apunta a $upstreamCurrent (esperaba $upstreamUrl)."
} else {
    Write-OK "upstream: $upstreamCurrent"
}

$tagCount = (git tag --list "lec-*-ok" | Measure-Object).Count
if ($tagCount -eq 0) {
    Write-Err "No hay tags 'lec-*-ok'. Ejecuta: git fetch --tags upstream"
} else {
    Write-OK "Tags 'lec-*-ok' descargados: $tagCount"
}

$branch = git rev-parse --abbrev-ref HEAD 2>$null
if ($branch -eq "main") {
    Write-Info "Rama actual: main (correcto entre lecciones)."
} elseif ($branch -match "^lec-\d{2}/[a-z0-9._-]+$") {
    Write-OK "Rama actual: $branch (formato correcto)."
} elseif ($branch -match "^lec-") {
    Write-Warn "Rama actual '$branch' no cumple lec-NN/<usuario> en minusculas."
} else {
    Write-Info "Rama actual: $branch"
}

$dirty = git status --porcelain 2>$null
if ($dirty) {
    Write-Warn "Hay cambios sin commitear en el working tree."
} else {
    Write-OK "Working tree limpio."
}

$gitName = git config --global user.name
$gitEmail = git config --global user.email
if (-not $gitName)  { Write-Err "Falta git config --global user.name" }  else { Write-OK "user.name: $gitName" }
if (-not $gitEmail) { Write-Err "Falta git config --global user.email" } else { Write-OK "user.email: $gitEmail" }

Write-Host ""
Write-Host "-- Variables de entorno --" -ForegroundColor Cyan
if ($env:GEMINI_API_KEY) {
    $masked = $env:GEMINI_API_KEY.Substring(0, [Math]::Min(6, $env:GEMINI_API_KEY.Length)) + "..."
    Write-OK "GEMINI_API_KEY definida (empieza por $masked)."
} else {
    Write-Err "GEMINI_API_KEY no definida en esta sesion."
}

Write-Host ""
Write-Host "-- Conectividad Ollama del centro --" -ForegroundColor Cyan
try {
    $resp = Invoke-WebRequest -Uri $ollamaUrl -TimeoutSec 5 -UseBasicParsing -ErrorAction Stop
    if ($resp.StatusCode -eq 200) {
        Write-OK "Ollama responde en $ollamaUrl"
    } else {
        Write-Warn "Ollama respondio con status $($resp.StatusCode)."
    }
} catch {
    Write-Warn "No se pudo contactar con $ollamaUrl ($($_.Exception.Message))."
    Write-Info "Si estas fuera de la red del centro es normal. Si estas dentro, avisa al profesor."
}

Write-Host ""
if ($script:errors -gt 0) {
    Write-Host "=== Resumen: $script:errors errores, $script:warns avisos ===" -ForegroundColor Red
    exit 1
} elseif ($script:warns -gt 0) {
    Write-Host "=== Resumen: 0 errores, $script:warns avisos ===" -ForegroundColor Yellow
    exit 0
} else {
    Write-Host "=== Resumen: todo OK ===" -ForegroundColor Green
    exit 0
}
