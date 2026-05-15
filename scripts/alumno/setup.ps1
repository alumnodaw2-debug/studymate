<#
.SYNOPSIS
  Setup inicial del alumno: configura 'upstream', trae tags, valida entorno.

.DESCRIPTION
  Ejecutar UNA SOLA VEZ, justo despues de clonar tu fork en este equipo.
  Si cambias de maquina, vuelve a ejecutarlo en la nueva. Es idempotente:
  pasarlo dos veces no rompe nada.
  Ver §3 de GUIA-ALUMNO.md.

.PARAMETER GithubUser
  Tu usuario de GitHub. Si se omite, se infiere del remoto 'origin'.

.EXAMPLE
  ./scripts/alumno/setup.ps1

.EXAMPLE
  ./scripts/alumno/setup.ps1 -GithubUser jdoe
#>
[CmdletBinding()]
param([string]$GithubUser)

$ErrorActionPreference = "Stop"
$upstreamUrl = "https://github.com/ichueca/studymate-curso.git"
$upstreamOwner = "ichueca"

function Write-OK($msg)   { Write-Host "  [OK]    $msg" -ForegroundColor Green }
function Write-Warn($msg) { Write-Host "  [WARN]  $msg" -ForegroundColor Yellow }
function Write-Err($msg)  { Write-Host "  [ERROR] $msg" -ForegroundColor Red }

Write-Host ""
Write-Host "=== Setup del alumno ===" -ForegroundColor Cyan
Write-Host ""

if (-not (Get-Command "git" -ErrorAction SilentlyContinue)) {
    Write-Err "git no esta en PATH. Instala Git 2.40+ antes de seguir."
    exit 1
}
Write-OK "git encontrado: $(git --version)"

git rev-parse --git-dir 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Err "No estas dentro de un repo git. cd a tu clon de studymate-curso."
    exit 1
}
Write-OK "Estas dentro de un repo git."

$originUrl = git remote get-url origin 2>$null
if (-not $originUrl) { Write-Err "No hay remoto 'origin'. Clon roto."; exit 1 }
if ($originUrl -match "/$upstreamOwner/studymate-curso(\.git)?$") {
    Write-Err "Tu 'origin' apunta al UPSTREAM ($originUrl)."
    Write-Err "Debes clonar TU FORK, no el repo del profesor."
    Write-Err "Solucion: borra este clon, ve a github.com/$upstreamOwner/studymate-curso, pulsa Fork, y clona desde tu fork."
    exit 1
}
Write-OK "origin: $originUrl"

if (-not $GithubUser -and $originUrl -match "github\.com[:/]([^/]+)/") {
    $GithubUser = $Matches[1]
}

$upstreamCurrent = git remote get-url upstream 2>$null
if (-not $upstreamCurrent) {
    git remote add upstream $upstreamUrl
    Write-OK "Anadido remoto 'upstream' -> $upstreamUrl"
} elseif ($upstreamCurrent -ne $upstreamUrl) {
    Write-Warn "'upstream' apuntaba a $upstreamCurrent. Lo corrijo."
    git remote set-url upstream $upstreamUrl
} else {
    Write-OK "upstream ya configurado: $upstreamUrl"
}

Write-Host "  Trayendo cambios y tags del upstream..." -ForegroundColor DarkGray
git fetch upstream 2>&1 | Out-Null
git fetch --tags upstream 2>&1 | Out-Null
$tagCount = (git tag --list "lec-*-ok" | Measure-Object).Count
Write-OK "Tags del curso descargados: $tagCount tags 'lec-*-ok'."

$gitName = git config --global user.name
$gitEmail = git config --global user.email
if (-not $gitName) {
    $inp = Read-Host "Tu nombre completo (para commits)"
    git config --global user.name $inp
    Write-OK "Configurado user.name = $inp"
} else {
    Write-OK "user.name: $gitName"
}
if (-not $gitEmail) {
    $inp = Read-Host "Tu email (el de GitHub)"
    git config --global user.email $inp
    Write-OK "Configurado user.email = $inp"
} else {
    Write-OK "user.email: $gitEmail"
}

if (Get-Command "java" -ErrorAction SilentlyContinue) {
    $javaVer = (java -version 2>&1 | Select-String "version" | Select-Object -First 1).ToString()
    if ($javaVer -match '"(\d+)') {
        $major = [int]$Matches[1]
        if ($major -ge 21) { Write-OK "Java $major detectado." }
        else { Write-Warn "Java $major < 21. Instala Eclipse Temurin 21 (§1.2 GUIA-ALUMNO.md)." }
    } else {
        Write-OK "Java instalado: $javaVer"
    }
} else {
    Write-Warn "java no esta en PATH. Necesitas Java 21 para arrancar studymate/."
}

if (Get-Command "mvn" -ErrorAction SilentlyContinue) {
    Write-OK "Maven en PATH."
} else {
    Write-Warn "Maven no esta en PATH (OK si solo lanzas desde Spring Tools, que lo embebe)."
}

if ($env:GEMINI_API_KEY) {
    Write-OK "GEMINI_API_KEY definida en esta sesion."
} else {
    Write-Warn "GEMINI_API_KEY no esta definida. Configurala con 'setx GEMINI_API_KEY \"AIzaSy...\"' (§2 GUIA-ALUMNO.md) y abre PowerShell nueva."
}

Write-Host ""
Write-Host "=== Setup completado ===" -ForegroundColor Green
Write-Host ""
if ($GithubUser) {
    Write-Host "Usuario detectado: $GithubUser" -ForegroundColor Cyan
    Write-Host "Para empezar una leccion (ejemplo L05), desde 'main' actualizado:"
    Write-Host ""
    Write-Host "  git checkout main"
    Write-Host "  git fetch upstream"
    Write-Host "  git merge upstream/main"
    Write-Host "  git push origin main"
    Write-Host "  git checkout -b lec-05/$GithubUser lec-04-refactor-y-router-ok"
} else {
    Write-Host "No he podido inferir tu usuario de GitHub del remoto 'origin'."
    Write-Host "Revisa el formato del clon. Cuando crees la rama de la leccion:"
    Write-Host "  git checkout -b lec-NN/<TU-USUARIO> <tag-de-partida>"
}
Write-Host ""
Write-Host "(El tag de partida lo da la cabecera del README de cada leccion.)"
Write-Host ""
