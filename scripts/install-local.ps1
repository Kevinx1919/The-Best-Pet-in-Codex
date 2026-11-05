param([string]$CodexHome = (Join-Path $env:USERPROFILE '.codex'))
$ErrorActionPreference = 'Stop'
$packageDirectory = Join-Path $PSScriptRoot '../pets/camo'
$sourceSheet = Join-Path $packageDirectory 'spritesheet.png'
$release = Get-Content -LiteralPath (Join-Path $packageDirectory 'release.json') -Raw | ConvertFrom-Json
$sourceHash = (Get-FileHash -LiteralPath $sourceSheet -Algorithm SHA256).Hash.ToLowerInvariant()
if ($sourceHash -ne $release.sha256) { throw 'La hoja no coincide con la distribución validada.' }
$destination = Join-Path ([IO.Path]::GetFullPath($CodexHome)) 'pets/camo'
$targetSheet = Join-Path $destination 'spritesheet.png'
$targetManifest = Join-Path $destination 'pet.json'
if (Test-Path -LiteralPath $targetSheet) {
    $existingHash = (Get-FileHash -LiteralPath $targetSheet -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($existingHash -ne $sourceHash) { throw 'Ya existe otra versión de Camo. Conserva una copia antes de reemplazarla.' }
}
if (Test-Path -LiteralPath $targetManifest) {
    $existingManifest = Get-Content -LiteralPath $targetManifest -Raw | ConvertFrom-Json
    if ($existingManifest.displayName -ne 'Camo' -or $existingManifest.spriteVersionNumber -ne 2 -or $existingManifest.spritesheetPath -ne 'spritesheet.png') {
        throw 'El manifiesto existente es distinto. Revísalo antes de reemplazarlo.'
    }
}
New-Item -ItemType Directory -Path $destination -Force | Out-Null
Copy-Item -LiteralPath $sourceSheet -Destination $targetSheet
Copy-Item -LiteralPath (Join-Path $packageDirectory 'pet.json') -Destination $targetManifest
if ((Get-FileHash -LiteralPath $targetSheet -Algorithm SHA256).Hash.ToLowerInvariant() -ne $sourceHash) { throw 'Falló la verificación de la copia.' }
Write-Output "Camo instalada en $destination"
Write-Output 'Abre Ajustes > Mascotas > Actualizar > Camo. La selección de Pets se realiza por separado.'
