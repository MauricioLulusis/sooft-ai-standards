---
name: sooft-development
description: Usar cuando hay una feature nueva, migración, refactor o cambio funcional; orquesta discovery, PRD, SPEC condicional, PLAN aprobado, implementación, revisión y PR.
---

# Development — driver de la rama FEATURE

> Esta skill es parte de SOOFT. Antes de usarla, seguí la skill `sooft` (principios, gates de aprobación, máquina de estados y reglas no negociables).

Este skill es un router de la rama `feat`. Conduce la máquina de estados de SOOFT y delega
cada paso a skills chicos. No reimplementa plantillas ni lógica de ejecución.

- Fuente de verdad de estados: la skill `sooft` (§4 Máquina de estados).
- `type` en `.sooft/state.json`: `feat`.
- Regla de oro: no escribir código hasta `phase == PLAN_APPROVED` o `IMPLEMENTING`.

## Ruta de skills

| Phase actual | Ejecutar | Output principal |
|---|---|---|
| `REQUIREMENT_LOADED` | recurso `internal/sooft-discovery.md` de `sooft` | resumen de discovery |
| `ANALYZED` | leé y seguí `assets/prd.md` | `docs/feats/{slug}/PRD.md` |
| `PRD_APPROVED` | leé y seguí `assets/technical-spec.md` si aplica; si no, `assets/implementation-plan.md` | `SPEC.md` o `PLAN.md` |
| `SPEC_APPROVED` | leé y seguí `assets/implementation-plan.md` | `PLAN.md` |
| `PLAN_REJECTED` | leé y seguí `assets/implementation-plan.md` | `PLAN.md` corregido |
| `PLAN_APPROVED` / `IMPLEMENTING` | recurso `internal/sooft-implement-task.md` de `sooft` | código/tests/evidencia + entradas en `.sooft/self-review-scratchpad.md` |
| `CODE_REVIEW_PENDING` | recurso `internal/sooft-code-review-gate.md` de `sooft` | aprobación humana con `docs/feats/{slug}/SELF-REVIEW.md` como input |

`/review` conduce `IMPLEMENTING → VALIDATING → CODE_REVIEW_PENDING` y usa el recurso
`internal/sooft-validation.md` de `sooft`, cuyo **último paso** consolida el sketchpad de
autoevaluación en `docs/feats/{slug}/SELF-REVIEW.md` siguiendo el template
`skills/sooft/assets/self-review-template.md`. Si aparecen hallazgos Very High/High, el flujo
pasa a `SECURITY_FINDINGS` y deriva al driver `sooft-security-remediation`.

Además, en **cada transición de fase** el agente mantiene `docs/feats/{slug}/STATUS.md`
(snapshot semántico compacto rehidratable) actualizado in-place, junto con un snapshot rotativo
en `.sooft/status/YYYY-MM-DDTHH-MM.md`. Contrato: `skills/sooft/assets/status-template.md`.
Compaction manual on-demand: skill `sooft-checkpoint`.

## Worktree

Antes de crear artefactos del trabajo, usar:

```bash
git worktree add .worktrees/feat-{slug} -b feat/{slug}
```

Todo el trabajo ocurre en `.worktrees/feat-{slug}`. El `{slug}` es corto y descriptivo
(ej: `user-auth`, `payment-refund`, `loan-migration`).

## Gates

- PRD: frase canónica de `assets/prd.md`.
- SPEC: frase canónica de `assets/technical-spec.md`, si aplica.
- PLAN: frase canónica de `assets/implementation-plan.md`.
- Código IA: frase canónica del recurso `internal/sooft-code-review-gate.md` de `sooft`.
- PR: no mergear hasta aprobación del developer/tech lead.

## Qué NO hacer

- No escribir código antes del plan aprobado.
- No saltear discovery, PRD, PLAN ni revisión de código `[IA-generated]`.
- No crear estados que no estén en la máquina de estados de la skill `sooft`.
- No duplicar instrucciones de primitives en este driver; actualizar el primitive dueño.
