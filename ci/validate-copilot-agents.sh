#!/usr/bin/env sh
# [IA-generated] SOOFT — revisar antes de mersooft. Ticket: N/A
# Validates GitHub Copilot CLI custom agents and SOOFT routing instructions.

set -eu

case "$0" in
  */*) SCRIPT_DIR=${0%/*} ;;
  *) SCRIPT_DIR=. ;;
esac
cd "$SCRIPT_DIR/.."

CR=$(printf '\r')
failures=0

fail() {
  failures=$((failures + 1))
  printf 'ERROR: %s\n' "$1" >&2
}

ok() {
  printf 'OK: %s\n' "$1"
}

require_file() {
  if [ ! -f "$1" ]; then
    fail "missing required file: $1"
  fi
}

contains_literal() {
  needle=$1
  file=$2
  while IFS= read -r line || [ -n "$line" ]; do
    line=${line%"$CR"}
    case "$line" in
      *"$needle"*) return 0 ;;
    esac
  done < "$file"
  return 1
}

contains_line_start() {
  prefix=$1
  file=$2
  while IFS= read -r line || [ -n "$line" ]; do
    line=${line%"$CR"}
    case "$line" in
      "$prefix"*) return 0 ;;
    esac
  done < "$file"
  return 1
}

require_contains() {
  needle=$1
  file=$2
  message=$3
  if ! contains_literal "$needle" "$file"; then
    fail "$message"
  fi
}

AGENTS="sooft-discovery sooft-prd-writer sooft-spec-architect sooft-plan-writer sooft-bug-analyst sooft-test-strategist sooft-security-reviewer sooft-code-reviewer sooft-evidence-writer sooft-release-writer"
MAIN_SKILLS="skills/sooft/SKILL.md skills/sooft-development/SKILL.md skills/sooft-bugs/SKILL.md skills/sooft-security-remediation/SKILL.md skills/sooft-status/SKILL.md skills/sooft-incident-response/SKILL.md"
KNOWN_MODELS="claude-haiku-4.5 claude-sonnet-4.6 gpt-5.3-codex gpt-5.4 gemini-3.1-pro-preview gemini-3.5-flash mai-code-1-flash"

require_file ".github/agents/MODELS.md"
require_file "skills/sooft/assets/agents/MODELS.md"
require_file ".github/copilot-instructions.md"
require_file "skills/sooft/assets/copilot-instructions.md"

for skill in $MAIN_SKILLS; do
  require_file "$skill"
done

agent_count=0
for agent_file in .github/agents/*.agent.md; do
  if [ -f "$agent_file" ]; then
    agent_count=$((agent_count + 1))
  fi
done

if [ "$agent_count" != "10" ]; then
  fail "expected 10 .agent.md files, found $agent_count"
else
  ok "found 10 custom agent profiles"
fi

for agent in $AGENTS; do
  file=".github/agents/$agent.agent.md"
  asset_file="skills/sooft/assets/agents/$agent.agent.md"
  require_file "$file"
  require_file "$asset_file"

  if ! cmp -s "$file" "$asset_file"; then
    fail "$asset_file is not synchronized with $file"
  fi

  delimiter_count=0
  name=""
  description=""
  model=""
  tools=""
  models_ref=0

  while IFS= read -r line || [ -n "$line" ]; do
    line=${line%"$CR"}
    case "$line" in
      ---) delimiter_count=$((delimiter_count + 1)) ;;
      name:*) name=${line#name:}; name=${name# } ;;
      description:*) description=${line#description:}; description=${description# } ;;
      model:*) model=${line#model:}; model=${model# } ;;
      tools:*) tools=${line#tools:}; tools=${tools# } ;;
    esac
    case "$line" in
      *'.github/agents/MODELS.md'*) models_ref=1 ;;
    esac
  done < "$file"

  if [ "$delimiter_count" -lt 2 ]; then
    fail "$file missing YAML frontmatter delimiters"
  fi
  if [ "$name" != "$agent" ]; then
    fail "$file name mismatch: expected $agent, found ${name:-<empty>}"
  fi
  if [ -z "$description" ]; then
    fail "$file missing description"
  fi
  if [ -z "$model" ]; then
    fail "$file missing model"
  fi
  if [ -z "$tools" ]; then
    fail "$file missing tools"
  fi
  if [ "$models_ref" != "1" ]; then
    fail "$file missing MODELS.md reference"
  fi
  require_contains '## Handoff to SOOFT orchestrator' "$file" "$file missing Handoff to SOOFT orchestrator section"
  require_contains 'contrato machine-readable' "$file" "$file must forbid translating machine-readable handoff headings"
  require_contains 'contrato machine-readable' "$asset_file" "$asset_file must forbid translating machine-readable handoff headings"
  require_contains '### Resultado' "$file" "$file missing handoff Resultado field"
  require_contains '### Evidencia usada' "$file" "$file missing handoff Evidencia usada field"
  require_contains '### Archivos leídos' "$file" "$file missing handoff Archivos leídos field"
  require_contains '### Archivos modificados' "$file" "$file missing handoff Archivos modificados field"
  require_contains '### Riesgos o bloqueos' "$file" "$file missing handoff Riesgos o bloqueos field"
  require_contains '### Requiere gate humano' "$file" "$file missing handoff Requiere gate humano field"
  require_contains '### Próximo paso sugerido' "$file" "$file missing handoff Próximo paso sugerido field"

  case " $KNOWN_MODELS " in
    *" $model "*) ;;
    *) fail "$file model $model is not in the documented model allowlist" ;;
  esac

  require_contains "$agent" ".github/copilot-instructions.md" ".github/copilot-instructions.md missing $agent"
  require_contains "$agent" "skills/sooft/assets/copilot-instructions.md" "skills/sooft/assets/copilot-instructions.md missing $agent"

  case "$agent" in
    sooft-discovery)
      route_files="skills/sooft/SKILL.md skills/sooft/internal/sooft-discovery.md"
      ;;
    sooft-prd-writer)
      route_files="skills/sooft/SKILL.md skills/sooft-development/assets/prd.md"
      ;;
    sooft-spec-architect)
      route_files="skills/sooft/SKILL.md skills/sooft-development/assets/technical-spec.md"
      ;;
    sooft-plan-writer)
      route_files="skills/sooft/SKILL.md skills/sooft-development/assets/implementation-plan.md"
      ;;
    sooft-bug-analyst)
      route_files="skills/sooft/SKILL.md skills/sooft-bugs/assets/bug-analysis.md skills/sooft-bugs/assets/bug-reproduction.md skills/sooft-bugs/assets/fix-plan.md"
      ;;
    sooft-test-strategist)
      route_files="skills/sooft/SKILL.md skills/sooft/internal/sooft-test-strategy.md skills/sooft-bugs/assets/bug-reproduction.md skills/sooft-bugs/assets/fix-plan.md"
      ;;
    sooft-security-reviewer)
      route_files="skills/sooft/SKILL.md skills/sooft/internal/sooft-validation.md skills/sooft/internal/sooft-code-review-gate.md skills/sooft-security-remediation/assets/security-findings.md skills/sooft-security-remediation/assets/security-scope.md skills/sooft-security-remediation/assets/remediation-plan.md"
      ;;
    sooft-code-reviewer)
      route_files="skills/sooft/SKILL.md skills/sooft/internal/sooft-validation.md skills/sooft/internal/sooft-code-review-gate.md"
      ;;
    sooft-evidence-writer)
      route_files="skills/sooft/SKILL.md skills/sooft/internal/sooft-evidence.md"
      ;;
    sooft-release-writer)
      route_files="skills/sooft/SKILL.md skills/sooft/internal/sooft-release.md"
      ;;
    *)
      route_files=""
      fail "$file has no routing case defined in the validator — add it to the case block"
      ;;
  esac

  if [ -z "$route_files" ]; then
    continue
  fi

  found_route=0
  for route_file in $route_files; do
    require_file "$route_file"
    if contains_literal "$agent" "$route_file"; then
      found_route=1
    fi
  done

  if ! cmp -s ".github/agents/MODELS.md" "skills/sooft/assets/agents/MODELS.md"; then
    fail "skills/sooft/assets/agents/MODELS.md is not synchronized with .github/agents/MODELS.md"
  fi
  if [ "$found_route" != "1" ]; then
    fail "no expected SOOFT routing file references $agent"
  fi

done

for reviewer in sooft-security-reviewer sooft-code-reviewer; do
  file=".github/agents/$reviewer.agent.md"
  tools_line=""
  while IFS= read -r line || [ -n "$line" ]; do
    line=${line%"$CR"}
    case "$line" in
      tools:*) tools_line=${line#tools:}; tools_line=${tools_line# } ;;
    esac
  done < "$file"

  # Allow-list: strip JSON punctuation, then verify every token is a permitted read-only tool
  stripped_tools=$(printf '%s' "$tools_line" | tr -d '[] "')
  read_only=1
  old_ifs=$IFS
  IFS=','
  for tool in $stripped_tools; do
    case "$tool" in
      read|search|grep|glob) ;;
      *) read_only=0 ;;
    esac
  done
  IFS=$old_ifs

  if [ "$read_only" = "0" ]; then
    fail "$file must be read-only; found non-allowed tool in: $tools_line"
  else
    ok "$reviewer is read-only (tools: $tools_line)"
  fi
done

for model in $KNOWN_MODELS; do
  model_is_used=0
  for file in .github/agents/*.agent.md; do
    if contains_line_start "model: $model" "$file"; then
      model_is_used=1
    fi
  done
  if [ "$model_is_used" = "1" ]; then
    require_contains "| \`$model\` |" ".github/agents/MODELS.md" "MODELS.md missing fallback row for $model"
  fi
done

require_contains 'model: auto' ".github/agents/MODELS.md" "MODELS.md must warn about model: auto"
require_contains 'model: auto' ".github/README-copilot.md" ".github/README-copilot.md must warn about model: auto"
require_contains 'NUNCA** aprueba PRD, SPEC, PLAN' "skills/sooft/SKILL.md" "skills/sooft/SKILL.md must state subagents never approve gates"
require_contains 'Handoff to SOOFT orchestrator' "skills/sooft/SKILL.md" "skills/sooft/SKILL.md must define the standard handoff"
require_contains 'subagente aplicable' "skills/sooft/SKILL.md" "skills/sooft/SKILL.md must prioritize applicable subagents"
require_contains 'copilot --agent sooft-discovery' "skills/sooft/SKILL.md" "skills/sooft/SKILL.md must document concrete sooft-discovery invocation"
require_contains 'preferencia de delegación' ".github/copilot-instructions.md" ".github/copilot-instructions.md must strongly prefer subagents"
require_contains 'preferencia de delegación' "skills/sooft/assets/copilot-instructions.md" "copilot instructions asset must strongly prefer subagents"
require_contains 'usá esos subagentes para el trabajo especializado' ".github/copilot-instructions.md" ".github/copilot-instructions.md must tell main agent to use custom agents"
require_contains 'usá esos subagentes para el trabajo especializado' "skills/sooft/assets/copilot-instructions.md" "copilot instructions asset must tell main agent to use custom agents"
require_contains 'usalo siempre que sea posible' "skills/sooft/internal/sooft-discovery.md" "sooft-discovery resource must strongly prefer subagent delegation"
require_contains 'Subagentes Copilot CLI' "AGENTS.md" "AGENTS.md must include subagent routing instructions"
require_contains 'Nunca** delegues gates' ".github/copilot-instructions.md" ".github/copilot-instructions.md must state gates are not delegated"
require_contains 'Nunca** delegues gates' "skills/sooft/assets/copilot-instructions.md" "copilot instructions asset must state gates are not delegated"

if [ "$failures" -ne 0 ]; then
  printf '\nCopilot agent validation failed with %s error(s).\n' "$failures" >&2
  exit 1
fi

printf '\nCopilot agent validation passed.\n'
