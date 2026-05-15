<#
.SYNOPSIS
  Cierra una lección: push de rama leccion/*, PR a main, espera checks, merge, tag y push del tag.

.DESCRIPTION
  Automatiza §5.4-§5.6 de GUIA-PROFESOR.md. Debe ejecutarse desde una rama
  'leccion/lec-NN-<slug>' con los commits del live coding ya hechos.

.PARAMETER Title
  Título del PR. Por defecto se deriva del nombre de la rama:
  'leccion/lec-06-system-prompt-tutor' -> '[L06] system prompt tutor'.

.PARAMETER DryRun
  Muestra el plan sin ejecutar nada.

.EXAMPLE
  ./scripts/cerrar-leccion.ps1

.EXAMPLE
  ./scripts/cerrar-leccion.ps1 -DryRun

.EXAMPLE
  ./scripts/cerrar-leccion.ps1 -Title "[L06] System prompt para el tutor"
#>
[CmdletBinding()]
param(
    [string]$Title,
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

function Invoke-Step {
    param([string]$Description, [scriptblock]$Command)
    Write-Host ""
    Write-Host "-> $Description" -ForegroundColor Cyan
    if ($DryRun) {
        Write-Host "   (dry-run) $($Command.ToString().Trim())" -ForegroundColor DarkGray
        return
    }
    & $Command
    if ($LASTEXITCODE -ne 0) { throw "Comando fallido en: $Description" }
}

# 1. Herramientas
foreach ($tool in @("git", "gh")) {
    if (-not (Get-Command $tool -ErrorAction SilentlyContinue)) {
        throw "Falta '$tool' en PATH."
    }
}

# 2. Autenticación gh
gh auth status 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) { throw "gh no autenticado. Ejecuta 'gh auth login'." }

# 3. Rama actual
$branch = (git rev-parse --abbrev-ref HEAD).Trim()
if (-not ($branch -match "^leccion/lec-(\d{2})-(.+)$")) {
    throw "Rama '$branch' no es 'leccion/lec-NN-<slug>'. Cambia a la rama de la lección antes de ejecutar."
}
$lessonNumber = $Matches[1]
$slug = $Matches[2]
$tagName = "lec-$lessonNumber-$slug-ok"

# 4. Working dir limpio
if (git status --porcelain) {
    throw "Working directory no limpio. Commit o stash los cambios primero."
}

# 5. El tag no debe existir ya
git rev-parse --verify "refs/tags/$tagName" 2>&1 | Out-Null
if ($LASTEXITCODE -eq 0) {
    throw "El tag '$tagName' ya existe. Borra el tag o cambia el slug de la rama."
}

# 6. Título del PR por defecto
if (-not $Title) {
    $readableSlug = $slug -replace "-", " "
    $Title = "[L$lessonNumber] $readableSlug"
}
$prBody = "Publicacion L$lessonNumber.`nTag de llegada: $tagName."

# 7. Ruta de la lección (para anuncio final)
$lessonFolder = Get-ChildItem -Path "programacion" -Directory -ErrorAction SilentlyContinue |
    ForEach-Object { Get-ChildItem -Path $_.FullName -Directory -ErrorAction SilentlyContinue } |
    Where-Object { $_.Name -eq "$lessonNumber-$slug" } |
    Select-Object -First 1
$lessonPath = if ($lessonFolder) {
    "programacion/$($lessonFolder.Parent.Name)/$($lessonFolder.Name)/"
} else { "(no encontrada en programacion/)" }

# 8. Resumen y confirmación
Write-Host ""
Write-Host "=== Cerrar leccion ===" -ForegroundColor Yellow
Write-Host "  Rama actual:   $branch"
Write-Host "  Titulo PR:     $Title"
Write-Host "  Tag a crear:   $tagName"
Write-Host "  Carpeta .md:   $lessonPath"
Write-Host "  Modo:          $(if ($DryRun) { 'DRY-RUN' } else { 'EJECUCION REAL' })"
Write-Host ""
$confirm = Read-Host "Continuar? [s/N]"
if ($confirm -notmatch "^[sS]$") {
    Write-Host "Cancelado." -ForegroundColor Yellow
    exit 0
}

# 9. Ejecutar la secuencia
Invoke-Step "Push de la rama al remoto" { git push -u origin $branch }

Invoke-Step "Crear PR contra main" {
    gh pr create --base main --head $branch --title $Title --body $prBody
}

Invoke-Step "Esperar a que los checks pasen (puede tardar 2-3 min)" {
    gh pr checks $branch --watch
}

Invoke-Step "Mergear PR (--merge, borra rama remota)" {
    gh pr merge $branch --merge --delete-branch
}

Invoke-Step "Volver a main y traer cambios" {
    git checkout main
    git pull origin main
}

Invoke-Step "Crear tag $tagName" { git tag $tagName }
Invoke-Step "Empujar tag al remoto" { git push origin $tagName }

# 10. Mensaje final
Write-Host ""
Write-Host "=== Leccion cerrada ===" -ForegroundColor Green
Write-Host "  Tag publicado: $tagName"
Write-Host ""
Write-Host "Anuncia en voz alta:" -ForegroundColor Yellow
Write-Host "  - Tag de llegada: $tagName"
Write-Host "  - .md de la leccion en: $lessonPath"
Write-Host ""
