---
name: sooft-security-remediation
description: Usar cuando hay vulnerabilidades, hallazgos de SAST/análisis estático, CVEs o auditorías; orquesta hallazgos, scope, plan aprobado, fixes y revisión.
---

# Security Remediation — driver de la rama SECURITY

> Esta skill es parte de SOOFT. Antes de usarla, seguí la skill `sooft` (principios, gates de aprobación, máquina de estados y reglas no negociables).

> **Proyección estructurada:** la máquina de estados de esta rama también vive en `workflow.yml`
> (mismo directorio) — formato declarativo, agnóstico a la herramienta.

Este skill es un router de la rama `security`. Conduce la máquina de estados de SOOFT y
delega cada paso a skills chicos.

- Fuente de verdad de estados: la skill `sooft` (§4 Máquina de estados).
- `type` en `.sooft/state.json`: `security`.
- Regla de oro: no aplicar fixes hasta `phase == REMEDIATION_PLAN_APPROVED` o `IMPLEMENTING`.

## Ruta de skills

| Phase actual | Ejecutar | Output principal |
|---|---|---|
| `REQUIREMENT_LOADED` | leé y seguí `assets/security-findings.md` | `FINDINGS.md` |
| `SECURITY_FINDINGS` | leé y seguí `assets/security-findings.md` | `FINDINGS.md` actualizado |
| `FINDINGS_DOCUMENTED` / `SCOPE_PENDING` | leé y seguí `assets/security-scope.md` | scope confirmado |
| `SCOPE_CONFIRMED` | leé y seguí `assets/remediation-plan.md` | `REMEDIATION_PLAN.md` |
| `REMEDIATION_PLAN_REJECTED` | leé y seguí `assets/remediation-plan.md` | plan corregido |
| `REMEDIATION_PLAN_APPROVED` / `IMPLEMENTING` | recurso `internal/sooft-implement-task.md` de `sooft` | fixes/tests/evidencia + entradas en `.sooft/self-review-scratchpad.md` |
| `CODE_REVIEW_PENDING` | recurso `internal/sooft-code-review-gate.md` de `sooft` | aprobación humana con `docs/security/{slug}/SELF-REVIEW.md` como input |

`/review` conduce `IMPLEMENTING → VALIDATING → CODE_REVIEW_PENDING` y usa el recurso
`internal/sooft-validation.md` de `sooft`, cuyo **último paso** consolida el sketchpad de
autoevaluación en `docs/security/{slug}/SELF-REVIEW.md` siguiendo el template
`skills/sooft/assets/self-review-template.md`. Si aparecen hallazgos Very High/High, el flujo
vuelve a `SECURITY_FINDINGS`.

Además, en **cada transición de fase** el agente mantiene `docs/security/{slug}/STATUS.md`
(snapshot semántico compacto rehidratable) actualizado in-place, junto con un snapshot rotativo
en `.sooft/status/YYYY-MM-DDTHH-MM.md`. Contrato: `skills/sooft/assets/status-template.md`.
Compaction manual on-demand: skill `sooft-checkpoint`.

## Worktree

```bash
git worktree add .worktrees/security-{slug} -b security/{slug}
```

Todo el trabajo ocurre en `.worktrees/security-{slug}`.

## Gates

- Scope: frase canónica de `assets/security-scope.md`.
- REMEDIATION_PLAN: frase canónica de `assets/remediation-plan.md`.
- Código IA: frase canónica del recurso `internal/sooft-code-review-gate.md` de `sooft`.
- PR: no mergear hasta aprobación del developer/tech lead y de Ciberseguridad si toca auth.

## Qué NO hacer

- No remediar hallazgos fuera del scope confirmado.
- No mezclar fixes de seguridad con features o refactors.
- No hardcodear secretos ni loguear PII.
- No mergear cambios de auth/autorización sin revisión de Ciberseguridad.
- No crear estados que no estén en la máquina de estados de la skill `sooft`.
