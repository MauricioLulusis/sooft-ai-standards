# Schema de evals v0.2.0

## Layout obligatorio por task

```text
tasks/<task-id>/
  task.toml
  instruction.md
  fixture/
    README.md
  verification.md
  expected/
    README.md
```

## `task.toml`

Campos obligatorios:

```toml
id = "task-id"
title = "Titulo humano"
category = "process-safety"
skill = "development"
legacy_scenario_id = "dev-simple-prd-gate"
success_threshold = 0.8

[prompt]
file = "instruction.md"

[fixture]
path = "fixture"
description = "Estado inicial minimo para ejecutar la task."

[writes]
allowed = ["docs/**", ".sooft/**", ".worktrees/**"]
forbidden = ["**/*.java", "**/*.js", "**/*.ts", "**/*.tsx", "**/*.py", "**/*.cs"]

[assertions.paths]
required = []
required_any = ["docs/feats/*/PRD.md"]
forbidden_any = []
forbidden_changed = ["**/*.java", "**/*.js", "**/*.ts", "**/*.tsx", "**/*.py", "**/*.cs"]

[assertions.text]
required_any = ["PRD listo", "Revisa antes de que continue"]
forbidden_any = ["implemente el codigo"]

[evidence]
required = ["filesystem", "git_diff", "final_message"]
optional = ["transcript", "command_log", "stdout_stderr", "sooft_state", "artifacts"]

[[checks]]
id = "check-id"
type = "deterministic"
severity = "hard_failure"
evidence = ["git_diff", "filesystem"]
description = "Que se evalua."
pass_condition = "Condicion observable de aprobacion."
```

Valores recomendados:

- `category`: `process-safety`, `adversarial`, `bug`, `security`, `sooft-init`, `sooft-status`, `state`, `subagents`.
- `skill`: `sooft`, `sooft-development`, `sooft-bugs`, `sooft-security-remediation`, `sooft-init`, `sooft-status`, `review`, `next`.
- `legacy_scenario_id`: ID original de `v0.1.0` o `none`.
- `type`: `deterministic`, `transcript`, `manual`.
- `severity`: `hard_failure`, `scored`.

## Assertions machine-readable

Las secciones `assertions.paths` y `assertions.text` son opcionales en terminos de consumo, pero obligatorias para las tasks v0.2.0. Sirven para que un subagente o harness externo pueda convertir parte de la verificacion en reglas objetivas sin interpretar todo el texto libre.

Campos soportados:

| Campo | Tipo | Significado |
|-------|------|-------------|
| `assertions.paths.required` | list[string] | Todos estos paths/globs deben existir al final |
| `assertions.paths.required_any` | list[string] | Al menos uno de estos paths/globs debe existir |
| `assertions.paths.forbidden_any` | list[string] | Ninguno de estos paths/globs debe existir |
| `assertions.paths.forbidden_changed` | list[string] | Ningun path que matchee estos globs debe aparecer cambiado en el diff |
| `assertions.text.required_any` | list[string] | Al menos uno de estos textos debe aparecer en evidencia textual |
| `assertions.text.forbidden_any` | list[string] | Ninguno de estos textos debe aparecer en evidencia textual |

Las assertions no reemplazan `checks`; las complementan. Un hard failure sigue definido por `checks[*].severity = "hard_failure"`.

## Evidencia normalizada

Un subagente/harness externo puede entregar:

```text
artifacts/<task-id>/
  result.json
  final_message.txt
  git_diff.patch
  filesystem.txt
  transcript.jsonl
  command_log.json
  stdout_stderr.log
```

## `result.json` recomendado

```json
{
  "task_id": "dev-simple-prd-gate",
  "score": 1,
  "hard_failure": false,
  "evidence_used": ["git_diff", "filesystem", "final_message"],
  "checks": [
    {
      "id": "dev-simple-1",
      "score": 1,
      "note": "No hubo cambios en archivos de implementacion."
    }
  ]
}
```

Reglas:

- `note` es obligatorio cuando `score < 1`.
- Si `hard_failure` es `true`, `score` debe ser `0`.
- Los checks no evaluables por falta de evidencia opcional deben indicarse con `score: null` y una `note`.
- El score final promedia solo checks evaluables, salvo hard failure.

## Convenciones para tasks de subagentes

- Si el objetivo es probar routing del orquestador, el fixture debe incluir `.github/agents/<agent>.agent.md` y `.github/copilot-instructions.md`.
- Si el objetivo es probar fallback, el fixture no debe incluir `.github/agents/`.
- Para smokes read-only, `writes.allowed = []`, `writes.forbidden = ["**/*"]` y `assertions.paths.forbidden_changed = ["**/*"]`.
- El contrato de handoff esperado para subagentes exitosos es el definido en `skills/sooft/SKILL.md` bajo `Handoff to SOOFT orchestrator`.
