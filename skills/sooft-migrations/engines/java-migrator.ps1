#!/usr/bin/env pwsh
#
# java-migrator.ps1 — Motor determinista de migración Java para SOOFT (/sooft-migrations).
# Espejo Windows/PowerShell de engines/java-migrator.sh. Lo invoca la skill sooft-migrations
# (NO el developer a mano). Es la pata "AST + build" del build-and-fix loop: aplica recetas
# OpenRewrite, compila el módulo afectado de forma incremental y dirigida, y deja los errores
# de compilación en un log que el subagente IA lee.
#
# Acciones (una por invocación, mutuamente excluyentes):
#   -SetupWorktree   -Branch <BRANCH> -Path <PATH>   Crea un Git Worktree aislado.
#   -ApplyRecipe     <RECIPE>                         Corre OpenRewrite (rewrite-maven-plugin:run).
#   -CompileModule   <MODULE>                         Compila solo el módulo (incremental, sin clean).
#   -CleanupWorktree <PATH>                            Elimina el Git Worktree temporal.
#
# Convención de logs: SIEMPRE en .sooft/migrations-logs/migration_errors.log (errores de compilación).
#
# Variables de entorno opcionales (con defaults seguros):
#   REWRITE_PLUGIN_VERSION   Versión del rewrite-maven-plugin.        
#   REWRITE_RECIPE_ARTIFACTS Coordenadas de artefactos de recetas.    
#   MVN_BIN                  Binario de Maven a usar.                 (default: mvn)
#   MVN_EXTRA_ARGS           Args extra para Maven (separados por espacio).

[CmdletBinding(DefaultParameterSetName = 'Help')]
param(
    [Parameter(ParameterSetName = 'SetupWorktree')]
    [switch]$SetupWorktree,

    [Parameter(ParameterSetName = 'SetupWorktree', Mandatory = $true)]
    [string]$Branch,

    [Parameter(ParameterSetName = 'SetupWorktree', Mandatory = $true)]
    [Parameter(ParameterSetName = 'CleanupWorktree', Mandatory = $true)]
    [string]$Path,

    [Parameter(ParameterSetName = 'ApplyRecipe', Mandatory = $true)]
    [string]$ApplyRecipe,

    [Parameter(ParameterSetName = 'CompileModule')]
    [AllowEmptyString()]
    [string]$CompileModule,


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

# Versión del plugin de OpenRewrite. Configurable por env. # [VERIFICAR contra Nexus de Sooft]
$RewritePluginVersion = if ($env:REWRITE_PLUGIN_VERSION) { $env:REWRITE_PLUGIN_VERSION } else { '5.42.0' }
# Artefactos que traen las recetas. # [VERIFICAR versiones]
$RewriteRecipeArtifacts = if ($env:REWRITE_RECIPE_ARTIFACTS) {
    $env:REWRITE_RECIPE_ARTIFACTS
} else {
    'org.openrewrite.recipe:rewrite-migrate-java:2.21.0,org.openrewrite.recipe:rewrite-spring:5.21.0'
}
$MvnBin = if ($env:MVN_BIN) { $env:MVN_BIN } else { 'mvn' }
$MvnExtraArgs = if ($env:MVN_EXTRA_ARGS) { $env:MVN_EXTRA_ARGS -split '\s+' | Where-Object { $_ } } else { @() }

# --------------------------------------------------------------------------------------
# Utilidades
# --------------------------------------------------------------------------------------
function Write-Info { param([string]$Message) Write-Host "[java-migrator] $Message" }
function Write-Err  { param([string]$Message) Write-Host "[java-migrator][ERROR] $Message" -ForegroundColor Red }

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

# Invoke-Maven: corre Maven persistiendo stderr+stdout en el log y devolviendo el exit code.
function Invoke-Maven {
    param([string[]]$MvnArgs)
    # Tee de toda la salida al log de errores que lee el subagente IA.
    & $MvnBin @MvnArgs 2>&1 | Tee-Object -FilePath $ErrLog -Append
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

function Invoke-ApplyRecipe {
    param([string]$Recipe)
    Assert-Command $MvnBin
    Reset-ErrLog

    Write-Info "Aplicando receta OpenRewrite: $Recipe"
    Write-Info "Plugin rewrite v$RewritePluginVersion · artefactos: $RewriteRecipeArtifacts"

    $args = @(
        '-B', '-U'
    ) + $MvnExtraArgs + @(
        "org.openrewrite.maven:rewrite-maven-plugin:${RewritePluginVersion}:run",
        "-Drewrite.activeRecipes=$Recipe",
        "-Drewrite.recipeArtifactCoordinates=$RewriteRecipeArtifacts"
    )

    $rc = Invoke-Maven -MvnArgs $args
    if ($rc -ne 0) {
        Write-Err "OpenRewrite falló (rc=$rc). Detalle en $ErrLog."
        exit $rc
    }
    Write-Info "Receta aplicada. Revisar el diff generado por OpenRewrite."
}

# Compila SOLO el módulo afectado, incremental y paralelo, SIN clean.
#   -T 1C  -> 1 thread por core (paralelo)
#   -o     -> offline (más rápido y determinista si está el cache)
#   -pl    -> project list: solo el módulo indicado
#   -am    -> also make: incluye dependencias necesarias del módulo (no todo el repo)
# (Sin 'clean' a propósito: compilación incremental para ahorrar tiempo.)
function Invoke-CompileModule {
    param([string]$ModuleName)
    Assert-Command $MvnBin
    Reset-ErrLog

    $args = @('-B', '-T', '1C', '-o')
    if (-not [string]::IsNullOrWhiteSpace($ModuleName)) {
        Write-Info "Compilando módulo dirigido '$ModuleName' (incremental, paralelo, sin clean)..."
        $args += @('-pl', $ModuleName, '-am')
    } else {
        Write-Info 'Compilando proyecto completo (incremental, paralelo, sin clean)...'
    }
    $args += $MvnExtraArgs
    $args += 'compile'

    $rc = Invoke-Maven -MvnArgs $args
    if ($rc -ne 0) {
        Write-Err "La compilación falló (rc=$rc). Errores en $ErrLog para reparación quirúrgica."
        exit $rc
    }
    Write-Info 'Compilación OK. Build en verde.'
}

function Show-Usage {
    @'
Uso: java-migrator.ps1 <acción> [args]

Acciones:
  -SetupWorktree   -Branch <BRANCH> -Path <PATH>   Crea un Git Worktree aislado.
  -ApplyRecipe     <RECIPE>                         Corre OpenRewrite con la receta indicada.
  -CompileModule   <MODULE>                         Compila solo el módulo (incremental, sin clean).
  -CleanupWorktree -Path <PATH>                     Elimina el Git Worktree temporal.

Ejemplos:
  ./java-migrator.ps1 -SetupWorktree -Branch migration/java-8-a-21 -Path .worktrees/migration-java-21
  ./java-migrator.ps1 -ApplyRecipe org.openrewrite.java.migrate.UpgradeToJava21
  ./java-migrator.ps1 -CompileModule payments-service
  ./java-migrator.ps1 -CleanupWorktree -Path .worktrees/migration-java-21
'@ | Write-Host
}

# --------------------------------------------------------------------------------------
# Dispatcher
# --------------------------------------------------------------------------------------
switch ($PSCmdlet.ParameterSetName) {
    'SetupWorktree'   { Invoke-SetupWorktree -BranchName $Branch -WorktreePath $Path }
    'ApplyRecipe'     { Invoke-ApplyRecipe -Recipe $ApplyRecipe }
    'CompileModule'   { Invoke-CompileModule -ModuleName $CompileModule }
    'CleanupWorktree' { Invoke-CleanupWorktree -WorktreePath $Path }
    default           { Show-Usage }
}
