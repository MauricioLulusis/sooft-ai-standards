---
name: sooft-development
description: Usar cuando hay una feature nueva, migración, refactor o cambio funcional; orquesta discovery, PRD, SPEC condicional, PLAN aprobado, implementación, revisión y PR.
---

# Development — driver de la rama FEATURE

> Esta skill es parte de SOOFT. Antes de usarla, seguí la skill `sooft` (principios, gates de aprobación, máquina de estados y reglas no negociables).

> **Proyección estructurada:** la máquina de estados de esta rama también vive en `workflow.yml`
> (mismo directorio) — formato declarativo, agnóstico a la herramienta, para runtimes que quieran
> validar transiciones sin depender de que un modelo interprete esta prosa.

Este skill es un router de la rama `feat`. Conduce la máquina de estados de SOOFT y delega
cada paso a skills chicos. No reimplementa plantillas ni lógica de ejecución.

- Fuente de verdad de estados: la skill `sooft` (§4 Máquina de estados). Fuente de verdad del rigor
  DIRECT/LEAN/FULL: skill `sooft` §3.1 — este driver no repite el criterio, solo lo aplica.
- `type` en `.sooft/state.json`: `feat`. Campo adicional `rigor`: `direct` · `lean` · `full`.
- Regla de oro: no escribir código hasta `phase == PLAN_APPROVED` o `IMPLEMENTING` — **salvo**
  `rigor == direct`, que llega a `IMPLEMENTING` desde `RIGOR_CONFIRMED` sin PRD ni PLAN (§3.1 de
  `sooft`). Ningún otro caso salta el plan.

## Ruta de skills

| Phase actual | Ejecutar | Output principal |
|---|---|---|
| `REQUIREMENT_LOADED` | recurso `internal/sooft-discovery.md` de `sooft` | resumen de discovery |
| `ANALYZED` | clasificá DIRECT/LEAN/FULL (criterio en `sooft` §3.1) y emití la frase canónica del gate 0 | `RIGOR_PENDING` → HALT hasta confirmación |
| `RIGOR_REJECTED` | reclasificá con el feedback del developer y volvé a emitir el gate 0 | `RIGOR_PENDING` |
| `RIGOR_CONFIRMED` (full) | leé y seguí `assets/prd.md` | `docs/feats/{slug}/PRD.md` |
| `RIGOR_CONFIRMED` (lean) | leé y seguí `assets/implementation-plan.md` directo (sin PRD ni SPEC) | `PLAN.md` |
| `RIGOR_CONFIRMED` (direct) | ubicá el cambio, aplicalo quirúrgicamente, sin crear PRD/SPEC/PLAN | diff mínimo, directo a `IMPLEMENTING` |
| `PRD_APPROVED` | leé y seguí `assets/technical-spec.md` si aplica; si no, `assets/implementation-plan.md` | `SPEC.md` o `PLAN.md` |
| `SPEC_APPROVED` | leé y seguí `assets/implementation-plan.md` | `PLAN.md` |
| `PLAN_REJECTED` | leé y seguí `assets/implementation-plan.md` | `PLAN.md` corregido |
| `PLAN_APPROVED` / `IMPLEMENTING` | recurso `internal/sooft-implement-task.md` de `sooft` | código/tests/evidencia + entradas en `.sooft/self-review-scratchpad.md` |
| `CODE_REVIEW_PENDING` | recurso `internal/sooft-code-review-gate.md` de `sooft` | aprobación humana con `docs/feats/{slug}/SELF-REVIEW.md` como input |

> **DIRECT sigue teniendo evidencia y revisión.** Aunque no hay PRD/SPEC/PLAN, `IMPLEMENTING` en
> rigor `direct` registra igual en `.sooft/evidence.md`, marca el diff `[IA-generated]` y pasa por
> `CODE_REVIEW_PENDING` como cualquier otra rama — la ceremonia que se saltea es la de
> planificación, nunca la de revisión (ver `sooft` §3.1).

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

- **Rigor (gate 0):** frase canónica en `sooft` §3. Obligatorio siempre en `feat`, antes que cualquier otro gate.
- PRD: frase canónica de `assets/prd.md`. Se omite si `rigor` es `lean` o `direct`.
- SPEC: frase canónica de `assets/technical-spec.md`, si aplica. Se omite si `rigor` es `lean` o `direct`.
- PLAN: frase canónica de `assets/implementation-plan.md`. Se omite si `rigor` es `direct`.
- Código IA: frase canónica del recurso `internal/sooft-code-review-gate.md` de `sooft`. **Nunca se omite, ni en DIRECT.**
- PR: no mergear hasta aprobación del developer/tech lead.

## Qué NO hacer

- No escribir código antes del plan aprobado — salvo `rigor == direct` ya confirmado en el gate 0.
- No saltear discovery, el gate de rigor, ni la revisión de código `[IA-generated]`.
- No clasificar DIRECT ante auth/sesión/tokens, ambigüedad, impacto en datos o pagos, ni migraciones — aunque el developer lo pida explícitamente (criterio completo en `sooft` §3.1).
- No inferir la confirmación de rigor de un pedido de saltar ceremonia: el gate 0 espera un OK explícito, igual que los demás.
- No crear estados que no estén en la máquina de estados de la skill `sooft`.
- No duplicar instrucciones de primitives en este driver; actualizar el primitive dueño.
