#!/usr/bin/env pwsh
#
# node-migrator.ps1 — Motor determinista de migración Node para SOOFT (/sooft-migrations).
# Espejo Windows/PowerShell de engines/node-migrator.sh. Lo invoca la skill sooft-migrations
# vía node-migration-agent (NO el developer a mano). Actualiza dependencias, aplica codemods
# AST, verifica tipos, buildea con webpack y corre tests, dejando los errores en un log que
# el subagente IA lee.
#
# Acciones (una por invocación, mutuamente excluyentes):
#   -SetupWorktree   -Branch <BRANCH> -Path <PATH>   Crea un Git Worktree aislado.
#   -UpdateDeps                                        Actualiza package.json con npm-check-updates.
#   -Install                                           Instala dependencias (npm install).
#   -ApplyCodemod    <TRANSFORM> [-CodemodPath <P>]    Aplica un codemod jscodeshift.
#   -Typecheck                                         Verifica tipos con tsc --noEmit.
#   -Build                                             Build completo (npm run build).
#   -RunTests                                          Corre los tests (npm test).
#   -CleanupWorktree -Path <PATH>                      Elimina el Git Worktree temporal.
#
# Convención de logs: SIEMPRE en .sooft/migrations-logs/migration_errors.log.
#
# Variables de entorno opcionales (con defaults seguros):
#   NPM_BIN           Binario de npm.                        (default: npm)
#   NPX_BIN           Binario de npx.                        (default: npx)
#   JEST_EXTRA_ARGS   Args extra para npm test (separados por espacio).
#   NCU_EXTRA_ARGS    Args extra para npm-check-updates (separados por espacio).

[CmdletBinding(DefaultParameterSetName = 'Help')]
param(
    [Parameter(ParameterSetName = 'SetupWorktree')]
    [switch]$SetupWorktree,

    [Parameter(ParameterSetName = 'SetupWorktree', Mandatory = $true)]
    [string]$Branch,

    [Parameter(ParameterSetName = 'SetupWorktree', Mandatory = $true)]
    [Parameter(ParameterSetName = 'CleanupWorktree', Mandatory = $true)]
    [string]$Path,

    [Parameter(ParameterSetName = 'UpdateDeps')]
    [switch]$UpdateDeps,

    [Parameter(ParameterSetName = 'Install')]
    [switch]$Install,

    [Parameter(ParameterSetName = 'ApplyCodemod', Mandatory = $true)]
    [string]$ApplyCodemod,

    [Parameter(ParameterSetName = 'ApplyCodemod')]
    [string]$CodemodPath = 'src',

    [Parameter(ParameterSetName = 'Typecheck')]
    [switch]$Typecheck,

    [Parameter(ParameterSetName = 'Build')]
    [switch]$Build,

    [Parameter(ParameterSetName = 'RunTests')]
    [switch]$RunTests,

    [Parameter(ParameterSetName = 'CleanupWorktree')]
    [switch]$CleanupWorktree
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# --------------------------------------------------------------------------------------
# Configuración y constantes
# --------------------------------------------------------------------------------------
$LogDir = '.sooft/migrations-logs'
$ErrLog = Join-Path $LogDir 'migration_errors.log'

$NpmBin = if ($env:NPM_BIN) { $env:NPM_BIN } else { 'npm' }
$NpxBin = if ($env:NPX_BIN) { $env:NPX_BIN } else { 'npx' }
$JestExtraArgs = if ($env:JEST_EXTRA_ARGS) { $env:JEST_EXTRA_ARGS -split '\s+' | Where-Object { $_ } } else { @() }
$NcuExtraArgs  = if ($env:NCU_EXTRA_ARGS)  { $env:NCU_EXTRA_ARGS  -split '\s+' | Where-Object { $_ } } else { @() }

# --------------------------------------------------------------------------------------
# Utilidades
# --------------------------------------------------------------------------------------
function Write-Info { param([string]$Message) Write-Host "[node-migrator] $Message" }
function Write-Err  { param([string]$Message) Write-Host "[node-migrator][ERROR] $Message" -ForegroundColor Red }

function Stop-WithError {
    param([string]$Message)
    Write-Err $Message
    exit 1
}

function Assert-Command {
    param([string]$Name)
    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        Stop-WithError "Comando requerido no encontrado en PATH: '$Name'."
    }
}

function Initialize-LogDir {
    if (-not (Test-Path -LiteralPath $LogDir)) {
        New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
    }
}

# Reset-ErrLog: limpia el log de errores de la corrida previa (deja archivo vacío).
function Reset-ErrLog {
    Initialize-LogDir
    Set-Content -LiteralPath $ErrLog -Value '' -NoNewline -Encoding utf8
}

# Invoke-NativeCommand: corre un binario nativo persistiendo la salida en el log.
function Invoke-NativeCommand {
    param([string]$Bin, [string[]]$Arguments)
    & $Bin @Arguments 2>&1 | Tee-Object -FilePath $ErrLog -Append
    return $LASTEXITCODE
}

# --------------------------------------------------------------------------------------
# Acciones
# --------------------------------------------------------------------------------------

function Invoke-SetupWorktree {
    param([string]$BranchName, [string]$WorktreePath)
    Assert-Command git

    if (Test-Path -LiteralPath $WorktreePath) {
        Stop-WithError "El path del worktree ya existe: $WorktreePath. Limpiarlo con -CleanupWorktree antes de recrearlo."
    }

    Write-Info "Creando worktree '$WorktreePath' sobre rama '$BranchName'..."
    & git worktree add $WorktreePath -b $BranchName
    if ($LASTEXITCODE -ne 0) {
        Stop-WithError "Falló 'git worktree add'. ¿La rama '$BranchName' ya existe o hay cambios sin commitear que lo impiden?"
    }
    Write-Info "Worktree listo en $WorktreePath."
}

function Invoke-CleanupWorktree {
    param([string]$WorktreePath)
    Assert-Command git

    if (-not (Test-Path -LiteralPath $WorktreePath)) {
        Write-Info "El worktree '$WorktreePath' no existe; nada que limpiar."
        return
    }

    Write-Info "Eliminando worktree '$WorktreePath'..."
    & git worktree remove $WorktreePath --force
    if ($LASTEXITCODE -ne 0) {
        Stop-WithError "Falló 'git worktree remove $WorktreePath'. Revisar manualmente con 'git worktree list'."
    }
    & git worktree prune
    Write-Info "Worktree '$WorktreePath' eliminado."
}

# Invoke-UpdateDeps: actualiza package.json en masa con npm-check-updates.
function Invoke-UpdateDeps {
    Assert-Command $NpxBin
    Reset-ErrLog

    Write-Info "Actualizando dependencias con npm-check-updates (-u)..."
    $ncuArgs = @('npm-check-updates', '-u') + $NcuExtraArgs
    $rc = Invoke-NativeCommand -Bin $NpxBin -Arguments $ncuArgs
    if ($rc -ne 0) {
        Write-Err "npm-check-updates falló (rc=$rc). Detalle en $ErrLog."
        exit $rc
    }
    Write-Info "package.json actualizado. Revisar el diff antes de instalar."
}

# Invoke-Install: instala las dependencias del package.json actualizado.
function Invoke-Install {
    Assert-Command $NpmBin
    Reset-ErrLog

    Write-Info "Instalando dependencias (npm install)..."
    $rc = Invoke-NativeCommand -Bin $NpmBin -Arguments @('install')
    if ($rc -ne 0) {
        Write-Err "npm install falló (rc=$rc). Errores en $ErrLog."
        exit $rc
    }
    Write-Info "Dependencias instaladas."
}

# Invoke-ApplyCodemod: corre jscodeshift con el transform dado sobre el path indicado.
function Invoke-ApplyCodemod {
    param([string]$Transform, [string]$TargetPath)
    Assert-Command $NpxBin
    Reset-ErrLog

    Write-Info "Aplicando codemod '$Transform' sobre '$TargetPath'..."
    $codemodArgs = @('jscodeshift', '-t', $Transform, $TargetPath, '--extensions=ts,tsx,js,jsx')
    $rc = Invoke-NativeCommand -Bin $NpxBin -Arguments $codemodArgs
    if ($rc -ne 0) {
        Write-Err "jscodeshift falló (rc=$rc). Detalle en $ErrLog."
        exit $rc
    }
    Write-Info "Codemod aplicado. Revisar el diff generado."
}

# Invoke-Typecheck: verifica tipos con tsc --noEmit (check rápido, sin emitir archivos).
function Invoke-Typecheck {
    Assert-Command $NpxBin
    Reset-ErrLog

    Write-Info "Verificando tipos con tsc --noEmit..."
    $rc = Invoke-NativeCommand -Bin $NpxBin -Arguments @('tsc', '--noEmit')
    if ($rc -ne 0) {
        Write-Err "tsc --noEmit falló (rc=$rc). Errores de tipos en $ErrLog."
        exit $rc
    }
    Write-Info "Type-check OK."
}

# Invoke-Build: build completo del proyecto (npm run build → webpack para NestJS Sooft).
function Invoke-Build {
    Assert-Command $NpmBin
    Reset-ErrLog

    Write-Info "Buildeando el proyecto (npm run build)..."
    $rc = Invoke-NativeCommand -Bin $NpmBin -Arguments @('run', 'build')
    if ($rc -ne 0) {
        Write-Err "npm run build falló (rc=$rc). Errores en $ErrLog."
        exit $rc
    }
    Write-Info "Build OK."
}

# Invoke-RunTests: corre los tests del proyecto (npm test).
function Invoke-RunTests {
    Assert-Command $NpmBin
    Reset-ErrLog

    Write-Info "Corriendo tests (npm test)..."
    if ($JestExtraArgs.Count -gt 0) {
        $testArgs = @('test', '--') + $JestExtraArgs
    } else {
        $testArgs = @('test')
    }
    $rc = Invoke-NativeCommand -Bin $NpmBin -Arguments $testArgs
    if ($rc -ne 0) {
        Write-Err "Los tests fallaron (rc=$rc). Detalle en $ErrLog."
        exit $rc
    }
    Write-Info "Tests OK. Revisar cobertura en el output (objetivo >= 90%)."
}

function Show-Usage {
    @'
Uso: node-migrator.ps1 <acción> [args]

Acciones:
  -SetupWorktree   -Branch <BRANCH> -Path <PATH>   Crea un Git Worktree aislado.
  -UpdateDeps                                        Actualiza package.json con npm-check-updates.
  -Install                                           Instala dependencias (npm install).
  -ApplyCodemod    <TRANSFORM> [-CodemodPath <P>]    Aplica un codemod jscodeshift.
  -Typecheck                                         Verifica tipos con tsc --noEmit.
  -Build                                             Build completo (npm run build).
  -RunTests                                          Corre los tests (npm test).
  -CleanupWorktree -Path <PATH>                      Elimina el Git Worktree temporal.

Ejemplos:
  ./node-migrator.ps1 -SetupWorktree -Branch migration/node-14-a-node-20 -Path .worktrees/migration-node-20
  ./node-migrator.ps1 -UpdateDeps
  ./node-migrator.ps1 -Install
  ./node-migrator.ps1 -ApplyCodemod ./codemods/update-imports.js -CodemodPath src/
  ./node-migrator.ps1 -Typecheck
  ./node-migrator.ps1 -Build
  ./node-migrator.ps1 -RunTests
  ./node-migrator.ps1 -CleanupWorktree -Path .worktrees/migration-node-20
'@ | Write-Host
}

# --------------------------------------------------------------------------------------
# Dispatcher
# --------------------------------------------------------------------------------------
switch ($PSCmdlet.ParameterSetName) {
    'SetupWorktree'   { Invoke-SetupWorktree -BranchName $Branch -WorktreePath $Path }
    'UpdateDeps'      { Invoke-UpdateDeps }
    'Install'         { Invoke-Install }
    'ApplyCodemod'    { Invoke-ApplyCodemod -Transform $ApplyCodemod -TargetPath $CodemodPath }
    'Typecheck'       { Invoke-Typecheck }
    'Build'           { Invoke-Build }
    'RunTests'        { Invoke-RunTests }
    'CleanupWorktree' { Invoke-CleanupWorktree -WorktreePath $Path }
    default           { Show-Usage }
}
