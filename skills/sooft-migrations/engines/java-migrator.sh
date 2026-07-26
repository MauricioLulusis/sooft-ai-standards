#!/usr/bin/env bash
#
# java-migrator.sh — Motor determinista de migración Java para SOOFT (/sooft-migrations).
# Lo invoca la skill sooft-migrations (NO el developer a mano). Es la pata "AST + build"
# del build-and-fix loop: aplica recetas OpenRewrite, compila el módulo afectado de forma
# incremental y dirigida, y deja los errores de compilación en un log que el subagente IA lee.
#
# Entornos: Unix (macOS / Linux). El espejo para Windows es engines/java-migrator.ps1.
#
# Acciones (una por invocación):
#   --setup-worktree   <BRANCH> <PATH>   Crea un Git Worktree aislado en <PATH> sobre la rama <BRANCH>.
#   --apply-recipe     <RECIPE>          Corre OpenRewrite (rewrite-maven-plugin:run) con la receta <RECIPE>.
#   --compile-module   <MODULE>          Compila SOLO <MODULE> incremental/paralelo, sin clean.
#   --cleanup-worktree <PATH>            Elimina el Git Worktree temporal en <PATH>.
#
# Convención de logs: SIEMPRE en .sooft/migrations-logs/migration_errors.log (errores de compilación).
#
# Variables de entorno opcionales (con defaults seguros):
#   REWRITE_PLUGIN_VERSION   Versión del rewrite-maven-plugin.        (default abajo)
#   REWRITE_RECIPE_ARTIFACTS Coordenadas de artefactos de recetas.    (coma-separadas)
#   MVN_BIN                  Binario de Maven a usar.                 (default: mvn)
#   MVN_EXTRA_ARGS           Args extra para pasar a Maven.           (default: vacío)

set -euo pipefail

# --------------------------------------------------------------------------------------
# Configuración y constantes
# --------------------------------------------------------------------------------------
readonly LOG_DIR=".sooft/migrations-logs"
readonly ERR_LOG="${LOG_DIR}/migration_errors.log"

# Versión del plugin de OpenRewrite. Configurable por env. # 
REWRITE_PLUGIN_VERSION="${REWRITE_PLUGIN_VERSION:-5.42.0}"
# Artefactos que traen las recetas (rewrite-migrate-java, rewrite-spring). # [VERIFICAR versiones]
REWRITE_RECIPE_ARTIFACTS="${REWRITE_RECIPE_ARTIFACTS:-org.openrewrite.recipe:rewrite-migrate-java:2.21.0,org.openrewrite.recipe:rewrite-spring:5.21.0}"
MVN_BIN="${MVN_BIN:-mvn}"
MVN_EXTRA_ARGS="${MVN_EXTRA_ARGS:-}"

# --------------------------------------------------------------------------------------
# Utilidades
# --------------------------------------------------------------------------------------

# log_info / log_err: mensajes de estado del motor (a stderr, para no contaminar stdout).
log_info() { printf '[java-migrator] %s\n' "$*" >&2; }
log_err()  { printf '[java-migrator][ERROR] %s\n' "$*" >&2; }

# die: aborta con mensaje y código de salida.
die() { log_err "$*"; exit 1; }

# require_cmd: verifica que un comando exista en el PATH.
require_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "Comando requerido no encontrado en PATH: '$1'."
}

# ensure_log_dir: crea .sooft/migrations-logs/ si no existe.
ensure_log_dir() {
  mkdir -p "${LOG_DIR}" || die "No se pudo crear el directorio de logs: ${LOG_DIR}"
}

# reset_err_log: limpia el log de errores de la corrida previa (deja archivo vacío).
reset_err_log() {
  ensure_log_dir
  : > "${ERR_LOG}" || die "No se pudo inicializar el log de errores: ${ERR_LOG}"
}

# usage: ayuda.
usage() {
  cat >&2 <<'EOF'
Uso: java-migrator.sh <acción> [args]

Acciones:
  --setup-worktree   <BRANCH> <PATH>   Crea un Git Worktree aislado.
  --apply-recipe     <RECIPE>          Corre OpenRewrite con la receta indicada.
  --compile-module   <MODULE>          Compila solo el módulo (incremental, sin clean).
  --cleanup-worktree <PATH>            Elimina el Git Worktree temporal.

Ejemplos:
  java-migrator.sh --setup-worktree migration/java-8-a-21 .worktrees/migration-java-21
  java-migrator.sh --apply-recipe org.openrewrite.java.migrate.UpgradeToJava21
  java-migrator.sh --compile-module payments-service
  java-migrator.sh --cleanup-worktree .worktrees/migration-java-21
EOF
}

# --------------------------------------------------------------------------------------
# Acciones
# --------------------------------------------------------------------------------------

# setup_worktree: crea un worktree aislado en <PATH> sobre una rama nueva <BRANCH>.
# El worktree garantiza que el workspace del developer no se toca durante la migración.
setup_worktree() {
  local branch="${1:-}" path="${2:-}"
  [ -n "${branch}" ] || die "--setup-worktree requiere <BRANCH>."
  [ -n "${path}" ]   || die "--setup-worktree requiere <PATH>."
  require_cmd git

  if [ -e "${path}" ]; then
    die "El path del worktree ya existe: ${path}. Limpiarlo con --cleanup-worktree antes de recrearlo."
  fi

  log_info "Creando worktree '${path}' sobre rama '${branch}'..."
  # -b crea la rama; si ya existe, git falla (intencional: evitamos pisar una rama existente).
  git worktree add "${path}" -b "${branch}" \
    || die "Falló 'git worktree add'. ¿La rama '${branch}' ya existe o hay cambios sin commitear que lo impiden?"
  log_info "Worktree listo en ${path}."
}

# cleanup_worktree: elimina el worktree temporal y poda referencias colgadas.
cleanup_worktree() {
  local path="${1:-}"
  [ -n "${path}" ] || die "--cleanup-worktree requiere <PATH>."
  require_cmd git

  if [ ! -e "${path}" ]; then
    log_info "El worktree '${path}' no existe; nada que limpiar."
    return 0
  fi

  log_info "Eliminando worktree '${path}'..."
  # --force porque el worktree puede tener cambios; el merge/PR ya se hizo antes de limpiar.
  git worktree remove "${path}" --force \
    || die "Falló 'git worktree remove ${path}'. Revisar manualmente con 'git worktree list'."
  git worktree prune || true
  log_info "Worktree '${path}' eliminado."
}

# apply_recipe: ejecuta OpenRewrite de forma determinista vía rewrite-maven-plugin:run.
# OpenRewrite reescribe en masa (el ~80% del trabajo). Los errores van al log.
apply_recipe() {
  local recipe="${1:-}"
  [ -n "${recipe}" ] || die "--apply-recipe requiere <RECIPE>."
  require_cmd "${MVN_BIN}"
  reset_err_log

  log_info "Aplicando receta OpenRewrite: ${recipe}"
  log_info "Plugin rewrite v${REWRITE_PLUGIN_VERSION} · artefactos: ${REWRITE_RECIPE_ARTIFACTS}"

  # -B batch (sin color/interactivo) · -U fuerza update de snapshots cuando aplica.
  # Capturamos stdout+stderr; si falla, persistimos el detalle en el log de errores.
  set +e
  ${MVN_BIN} -B -U ${MVN_EXTRA_ARGS} \
    "org.openrewrite.maven:rewrite-maven-plugin:${REWRITE_PLUGIN_VERSION}:run" \
    "-Drewrite.activeRecipes=${recipe}" \
    "-Drewrite.recipeArtifactCoordinates=${REWRITE_RECIPE_ARTIFACTS}" \
    2> >(tee -a "${ERR_LOG}" >&2)
  local rc=$?
  set -e

  if [ "${rc}" -ne 0 ]; then
    log_err "OpenRewrite falló (rc=${rc}). Detalle en ${ERR_LOG}."
    return "${rc}"
  fi
  log_info "Receta aplicada. Revisar el diff generado por OpenRewrite."
}

# compile_module: compila SOLO el módulo afectado, incremental y paralelo, SIN clean.
# Optimización para monorepos grandes: no recompila todo el árbol.
#   -T 1C  -> 1 thread por core (paralelo)
#   -o     -> offline (no resuelve red si ya está el cache; más rápido y determinista)
#   -pl    -> project list: solo el módulo indicado
#   -am    -> also make: incluye dependencias necesarias del módulo (no todo el repo)
# (Sin 'clean' a propósito: compilación incremental para ahorrar tiempo.)
compile_module() {
  local module="${1:-}"
  require_cmd "${MVN_BIN}"
  reset_err_log

  local -a mvn_args
  mvn_args=(-B -T 1C -o)
  if [ -n "${module}" ]; then
    log_info "Compilando módulo dirigido '${module}' (incremental, paralelo, sin clean)..."
    mvn_args+=(-pl "${module}" -am)
  else
    log_info "Compilando proyecto completo (incremental, paralelo, sin clean)..."
  fi
  mvn_args+=(compile)

  # Ejecutamos compilando; persistimos SOLO los errores en el log que el subagente IA lee.
  set +e
  # shellcheck disable=SC2086 # MVN_EXTRA_ARGS debe expandirse en palabras.
  ${MVN_BIN} "${mvn_args[@]}" ${MVN_EXTRA_ARGS} 2> >(tee -a "${ERR_LOG}" >&2)
  local rc=$?
  set -e

  if [ "${rc}" -ne 0 ]; then
    log_err "La compilación falló (rc=${rc}). Errores en ${ERR_LOG} para reparación quirúrgica."
    return "${rc}"
  fi
  log_info "Compilación OK. Build en verde."
}

# --------------------------------------------------------------------------------------
# Dispatcher
# --------------------------------------------------------------------------------------
main() {
  [ "$#" -ge 1 ] || { usage; die "Falta la acción."; }

  local action="$1"; shift
  case "${action}" in
    --setup-worktree)   setup_worktree "${1:-}" "${2:-}" ;;
    --apply-recipe)     apply_recipe "${1:-}" ;;
    --compile-module)   compile_module "${1:-}" ;;
    --cleanup-worktree) cleanup_worktree "${1:-}" ;;
    -h|--help)          usage ;;
    *)                  usage; die "Acción desconocida: ${action}" ;;
  esac
}

main "$@"
