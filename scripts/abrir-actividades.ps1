<#
.SYNOPSIS
  Crea la rama local de resolución de actividades partiendo del tag de la lección.

.DESCRIPTION
  Automatiza el inicio de §8.4 de GUIA-PROFESOR.md: parte del tag 'lec-NN-<slug>-ok'
  para crear la rama 'solucion/lec-NN-actividades'. La rama es desechable y NO se
  debe pushear (rompería §8: el solucionario nunca sale del clon local).

.PARAMETER Number
  Número de la lección (1-18). Si se omite, se pregunta interactivamente.

.PARAMETER Tag
  Tag concreto desde el que partir. Si se omite, se busca un tag único que case
  con 'lec-NN-*-ok'.

.EXAMPLE
  ./scripts/abrir-actividades.ps1 -Number 5

.EXAMPLE
  ./scripts/abrir-actividades.ps1 -Tag lec-05-primer-endpoint-chat-ok
#>
[CmdletBinding()]
param(
    [int]$Number,
    [string]$Tag
)

$ErrorActionPreference = "Stop"

# 1. Herramientas
if (-not (Get-Command "git" -ErrorAction SilentlyContinue)) {
    throw "Falta 'git' en PATH."
}

# 2. Determinar el tag
if (-not $Tag) {
    if (-not $Number) {
        $inputN = Read-Host "Numero de leccion (01-18)"
        $Number = [int]$inputN
    }
    $padded = "{0:D2}" -f $Number

    # Refrescar tags por si el remoto tiene alguno más reciente
    git fetch --tags origin 2>&1 | Out-Null

    $matches = git tag --list "lec-$padded-*-ok"
    if (-not $matches) {
        throw "No hay tag 'lec-$padded-*-ok'. Cierra la leccion primero con cerrar-leccion.ps1."
    }
    $tagsArray = @($matches -split "`n" | Where-Object { $_ })
    if ($tagsArray.Count -gt 1) {
        Write-Host "Varios tags candidatos:" -ForegroundColor Yellow
        $tagsArray | ForEach-Object { Write-Host "  - $_" }
        $Tag = Read-Host "Escribe el tag exacto"
    } else {
        $Tag = $tagsArray[0].Trim()
    }
}

# 3. Validar formato del tag
if (-not ($Tag -match "^lec-(\d{2})-(.+)-ok$")) {
    throw "El tag '$Tag' no cumple 'lec-NN-<slug>-ok'."
}
$lessonNumber = $Matches[1]

# 4. Working dir limpio
if (git status --porcelain) {
    throw "Working directory no limpio. Commit o stash primero."
}

# 5. Nombre de la rama
$branchName = "solucion/lec-$lessonNumber-actividades"

# 6. La rama no debe existir ya
git rev-parse --verify "refs/heads/$branchName" 2>&1 | Out-Null
if ($LASTEXITCODE -eq 0) {
    throw "La rama '$branchName' ya existe. Usa 'git checkout $branchName' o borrala con 'git branch -D $branchName'."
}

# 7. Verificar que el tag existe en local
git rev-parse --verify "refs/tags/$Tag" 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
    throw "El tag '$Tag' no existe en tu clon. Prueba 'git fetch --tags origin'."
}

# 8. Crear la rama desde el tag
Write-Host "Creando rama '$branchName' desde tag '$Tag'..." -ForegroundColor Cyan
git checkout -b $branchName $Tag
if ($LASTEXITCODE -ne 0) { throw "git checkout fallo." }

# 9. Mensaje final
Write-Host ""
Write-Host "=== Rama de soluciones lista ===" -ForegroundColor Green
Write-Host "  Rama:     $branchName"
Write-Host "  Parte de: $Tag"
Write-Host ""
Write-Host "Resuelve las actividades aqui. Cuando termines:" -ForegroundColor Yellow
Write-Host "  1. Copia los snippets relevantes al actividades.solucionario.md"
Write-Host "     de la leccion (protegido por .gitignore)."
Write-Host "  2. NUNCA hagas 'git push' de esta rama."
Write-Host "  3. Para volver al estado limpio:"
Write-Host "       git checkout main"
Write-Host "       git branch -D $branchName"
Write-Host ""
