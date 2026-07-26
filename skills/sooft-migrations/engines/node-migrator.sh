#!/usr/bin/env bash
#
# node-migrator.sh — Motor determinista de migración Node para SOOFT (/sooft-migrations).
# Lo invoca la skill sooft-migrations vía node-migration-agent (NO el developer a mano).
# Es la pata "deps + codemods + typecheck + build + tests" del build-and-fix loop: actualiza
# dependencias con npm-check-updates, aplica codemods AST con jscodeshift (cuando aplica),
# verifica tipos con tsc, buildea con webpack y corre la suite de tests, dejando los errores
# en un log que el subagente IA lee.
#
# Entornos: Unix (macOS / Linux). El espejo para Windows es engines/node-migrator.ps1.
#
# Acciones (una por invocación):
#   --setup-worktree   <BRANCH> <PATH>          Crea un Git Worktree aislado en <PATH> sobre <BRANCH>.
#   --update-deps                                Actualiza package.json con npm-check-updates (-u).
#   --install                                    Instala dependencias (npm install).
#   --apply-codemod    <TRANSFORM> [<PATH>]      Corre jscodeshift con el transform dado sobre <PATH>.
#   --typecheck                                  Verifica tipos con tsc --noEmit.
#   --build                                      Build completo (npm run build — webpack).
#   --run-tests                                  Corre los tests del proyecto (npm test).
#   --cleanup-worktree <PATH>                    Elimina el Git Worktree temporal.
#
# Convención de logs: SIEMPRE en .sooft/migrations-logs/migration_errors.log (errores de build/tests).
#
# Variables de entorno opcionales (con defaults seguros):
#   NPM_BIN           Binario de npm.                        (default: npm)
#   NPX_BIN           Binario de npx.                        (default: npx)
#   JEST_EXTRA_ARGS   Args extra para jest (vía npm test --). (default: vacío)
#   NCU_EXTRA_ARGS    Args extra para npm-check-updates.      (default: vacío)

set -euo pipefail

# --------------------------------------------------------------------------------------
# Configuración y constantes
# --------------------------------------------------------------------------------------
readonly LOG_DIR=".sooft/migrations-logs"
readonly ERR_LOG="${LOG_DIR}/migration_errors.log"

NPM_BIN="${NPM_BIN:-npm}"
NPX_BIN="${NPX_BIN:-npx}"
JEST_EXTRA_ARGS="${JEST_EXTRA_ARGS:-}"
NCU_EXTRA_ARGS="${NCU_EXTRA_ARGS:-}"

# --------------------------------------------------------------------------------------
# Utilidades
# --------------------------------------------------------------------------------------

log_info() { printf '[node-migrator] %s\n' "$*" >&2; }
log_err()  { printf '[node-migrator][ERROR] %s\n' "$*" >&2; }
die()      { log_err "$*"; exit 1; }

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "Comando requerido no encontrado en PATH: '$1'."
}

ensure_log_dir() {
  mkdir -p "${LOG_DIR}" || die "No se pudo crear el directorio de logs: ${LOG_DIR}"
}

reset_err_log() {
  ensure_log_dir
  : > "${ERR_LOG}" || die "No se pudo inicializar el log de errores: ${ERR_LOG}"
}

usage() {
  cat >&2 <<'EOF'
Uso: node-migrator.sh <acción> [args]

Acciones:
  --setup-worktree   <BRANCH> <PATH>          Crea un Git Worktree aislado.
  --update-deps                                Actualiza package.json con npm-check-updates.
  --install                                    Instala dependencias (npm install).
  --apply-codemod    <TRANSFORM> [<PATH>]      Aplica un codemod jscodeshift (default PATH: src).
  --typecheck                                  Verifica tipos con tsc --noEmit.
  --build                                      Build completo (npm run build).
  --run-tests                                  Corre los tests del proyecto (npm test).
  --cleanup-worktree <PATH>                    Elimina el Git Worktree temporal.

Ejemplos:
  node-migrator.sh --setup-worktree migration/node-14-a-node-20 .worktrees/migration-node-20
  node-migrator.sh --update-deps
  node-migrator.sh --install
  node-migrator.sh --apply-codemod ./codemods/update-imports.js src/
  node-migrator.sh --typecheck
  node-migrator.sh --build
  node-migrator.sh --run-tests
  node-migrator.sh --cleanup-worktree .worktrees/migration-node-20
EOF
}

# --------------------------------------------------------------------------------------
# Acciones
# --------------------------------------------------------------------------------------

# setup_worktree: crea un worktree aislado en <PATH> sobre una rama nueva <BRANCH>.
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

# update_deps: actualiza package.json en masa con npm-check-updates.
# Equivalente conceptual al --apply-recipe de java-migrator pero para dependencias npm.
# ncu -u modifica package.json en el lugar; el --install posterior materializa los cambios.
update_deps() {
  require_cmd "${NPX_BIN}"
  reset_err_log

  log_info "Actualizando dependencias con npm-check-updates (-u)..."
  set +e
  # shellcheck disable=SC2086
  ${NPX_BIN} npm-check-updates -u ${NCU_EXTRA_ARGS} \
    2> >(tee -a "${ERR_LOG}" >&2)
  local rc=$?
  set -e

  if [ "${rc}" -ne 0 ]; then
    log_err "npm-check-updates falló (rc=${rc}). Detalle en ${ERR_LOG}."
    return "${rc}"
  fi
  log_info "package.json actualizado. Revisar el diff antes de instalar."
}

# install_deps: instala las dependencias del package.json actualizado.
install_deps() {
  require_cmd "${NPM_BIN}"
  reset_err_log

  log_info "Instalando dependencias (npm install)..."
  set +e
  ${NPM_BIN} install 2> >(tee -a "${ERR_LOG}" >&2)
  local rc=$?
  set -e

  if [ "${rc}" -ne 0 ]; then
    log_err "npm install falló (rc=${rc}). Errores en ${ERR_LOG}."
    return "${rc}"
  fi
  log_info "Dependencias instaladas."
}

# apply_codemod: corre jscodeshift con el transform dado sobre el path indicado.
# Análogo a --apply-recipe pero para transformaciones de código fuente (renombrado de APIs,
# imports, etc.). El subagente proporciona el transform; el motor lo ejecuta.
apply_codemod() {
  local transform="${1:-}" target="${2:-src}"
  [ -n "${transform}" ] || die "--apply-codemod requiere <TRANSFORM>."
  require_cmd "${NPX_BIN}"
  reset_err_log

  log_info "Aplicando codemod '${transform}' sobre '${target}'..."
  set +e
  ${NPX_BIN} jscodeshift -t "${transform}" "${target}" --extensions=ts,tsx,js,jsx \
    2> >(tee -a "${ERR_LOG}" >&2)
  local rc=$?
  set -e

  if [ "${rc}" -ne 0 ]; then
    log_err "jscodeshift falló (rc=${rc}). Detalle en ${ERR_LOG}."
    return "${rc}"
  fi
  log_info "Codemod aplicado. Revisar el diff generado."
}

# typecheck: verifica tipos con tsc --noEmit.
# Check rápido (sin emitir archivos) para detectar errores de tipos antes del build completo.
# Equivalente conceptual al --compile-module incremental de java-migrator.
typecheck() {
  require_cmd "${NPX_BIN}"
  reset_err_log

  log_info "Verificando tipos con tsc --noEmit..."
  set +e
  ${NPX_BIN} tsc --noEmit 2> >(tee -a "${ERR_LOG}" >&2)
  local rc=$?
  set -e

  if [ "${rc}" -ne 0 ]; then
    log_err "tsc --noEmit falló (rc=${rc}). Errores de tipos en ${ERR_LOG}."
    return "${rc}"
  fi
  log_info "Type-check OK."
}

# build_project: build completo del proyecto (npm run build → webpack).
# Para proyectos Sooft NestJS, esto corre 'nest build --webpack'.
build_project() {
  require_cmd "${NPM_BIN}"
  reset_err_log

  log_info "Buildeando el proyecto (npm run build)..."
  set +e
  ${NPM_BIN} run build 2> >(tee -a "${ERR_LOG}" >&2)
  local rc=$?
  set -e

  if [ "${rc}" -ne 0 ]; then
    log_err "npm run build falló (rc=${rc}). Errores en ${ERR_LOG}."
    return "${rc}"
  fi
  log_info "Build OK."
}

# run_tests: corre los tests del proyecto vía npm test.
# Para proyectos NestJS Sooft, jest hereda la config del scope de las librerías compartidas del proyecto (commons).
run_tests() {
  require_cmd "${NPM_BIN}"
  reset_err_log

  log_info "Corriendo tests (npm test)..."
  set +e
  if [ -n "${JEST_EXTRA_ARGS}" ]; then
    # shellcheck disable=SC2086
    ${NPM_BIN} test -- ${JEST_EXTRA_ARGS} 2> >(tee -a "${ERR_LOG}" >&2)
  else
    ${NPM_BIN} test 2> >(tee -a "${ERR_LOG}" >&2)
  fi
  local rc=$?
  set -e

  if [ "${rc}" -ne 0 ]; then
    log_err "Los tests fallaron (rc=${rc}). Detalle en ${ERR_LOG}."
    return "${rc}"
  fi
  log_info "Tests OK. Revisar cobertura en el output (objetivo ≥ 90%)."
}

# --------------------------------------------------------------------------------------
# Dispatcher
# --------------------------------------------------------------------------------------
main() {
  [ "$#" -ge 1 ] || { usage; die "Falta la acción."; }

  local action="$1"; shift
  case "${action}" in
    --setup-worktree)   setup_worktree "${1:-}" "${2:-}" ;;
    --update-deps)      update_deps ;;
    --install)          install_deps ;;
    --apply-codemod)    apply_codemod "${1:-}" "${2:-}" ;;
    --typecheck)        typecheck ;;
    --build)            build_project ;;
    --run-tests)        run_tests ;;
    --cleanup-worktree) cleanup_worktree "${1:-}" ;;
    -h|--help)          usage ;;
    *)                  usage; die "Acción desconocida: ${action}" ;;
  esac
}

main "$@"
