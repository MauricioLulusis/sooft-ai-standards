# Migracion v0.1.0 -> v0.2.0

`evals/v0.1.0/` (la suite legacy, 7 escenarios en un unico `evals.json`) fue removida del repo una
vez completada y verificada la migracion: los 7 escenarios estan cubiertos 1:1 abajo y la suite
vigente es `evals/` (este directorio). Esta tabla queda como registro historico de la migracion.

## Escenarios

| v0.1.0 scenario | v0.2.0 task | Estado |
|-----------------|-------------|--------|
| `dev-simple-prd-gate` | `tasks/dev-simple-prd-gate/` | Migrado |
| `dev-complex-spec-required` | `tasks/dev-complex-spec-required/` | Migrado |
| `bugs-no-code-before-plan` | `tasks/bugs-no-code-before-plan/` | Migrado |
| `security-scope-before-fixes` | `tasks/security-scope-before-fixes/` | Migrado |
| `no-vibe-coding` | `tasks/no-vibe-coding/` | Migrado |
| `init-no-long-questionnaire` | `tasks/init-no-long-questionnaire/` | Migrado |
| `status-no-invention` | `tasks/status-no-invention/` | Migrado |
| N/A | `tasks/dev-adversarial-skip-prd/` | Nuevo |
| N/A | `tasks/dev-ambiguous-approval/` | Nuevo |
| N/A | `tasks/invalid-state-blocks-progress/` | Nuevo |
| N/A | `tasks/subagent-discovery-routing-required/` | Nuevo |
| N/A | `tasks/subagent-handoff-contract/` | Nuevo |
| N/A | `tasks/subagent-discovery-fallback/` | Nuevo |

## Expectations legacy

| Expectation v0.1.0 | Task v0.2.0 | Check v0.2.0 |
|--------------------|-------------|--------------|
| `dev-simple-1` | `dev-simple-prd-gate` | `dev-simple-1` |
| `dev-simple-2` | `dev-simple-prd-gate` | `dev-simple-2` |
| `dev-simple-3` | `dev-simple-prd-gate` | `dev-simple-3` |
| `dev-simple-4` | `dev-simple-prd-gate` | `dev-simple-4` |
| `dev-simple-5` | `dev-simple-prd-gate` | `dev-simple-5` |
| `dev-complex-1` | `dev-complex-spec-required` | `dev-complex-1` |
| `dev-complex-2` | `dev-complex-spec-required` | `dev-complex-2` |
| `dev-complex-3` | `dev-complex-spec-required` | `dev-complex-3` |
| `dev-complex-4` | `dev-complex-spec-required` | `dev-complex-4` |
| `bugs-1` | `bugs-no-code-before-plan` | `bugs-1` |
| `bugs-2` | `bugs-no-code-before-plan` | `bugs-2` |
| `bugs-3` | `bugs-no-code-before-plan` | `bugs-3` |
| `bugs-4` | `bugs-no-code-before-plan` | `bugs-4` |
| `bugs-5` | `bugs-no-code-before-plan` | `bugs-5` |
| `security-1` | `security-scope-before-fixes` | `security-1` |
| `security-2` | `security-scope-before-fixes` | `security-2` |
| `security-3` | `security-scope-before-fixes` | `security-3` |
| `security-4` | `security-scope-before-fixes` | `security-4` |
| `novibe-1` | `no-vibe-coding` | `novibe-1` |
| `novibe-2` | `no-vibe-coding` | `novibe-2` |
| `novibe-3` | `no-vibe-coding` | `novibe-3` |
| `novibe-4` | `no-vibe-coding` | `novibe-4` |
| `init-1` | `init-no-long-questionnaire` | `init-1` |
| `init-2` | `init-no-long-questionnaire` | `init-2` |
| `init-3` | `init-no-long-questionnaire` | `init-3` |
| `init-4` | `init-no-long-questionnaire` | `init-4` |
| `init-5` | `init-no-long-questionnaire` | `init-5` |
| `status-1` | `status-no-invention` | `status-1` |
| `status-2` | `status-no-invention` | `status-2` |
| `status-3` | `status-no-invention` | `status-3` |
| `status-4` | `status-no-invention` | `status-4` |

## Hard failures migrados

| Hard failure legacy | Task | Check |
|---------------------|------|-------|
| `dev-simple-1` | `dev-simple-prd-gate` | `severity = "hard_failure"` |
| `dev-complex-2` | `dev-complex-spec-required` | `severity = "hard_failure"` |
| `bugs-1` | `bugs-no-code-before-plan` | `severity = "hard_failure"` |
| `security-1` | `security-scope-before-fixes` | `severity = "hard_failure"` |
| `novibe-1` | `no-vibe-coding` | `severity = "hard_failure"` |
| `status-2` | `status-no-invention` | `severity = "hard_failure"` |
