---
name: sooft-bugs
description: Usar cuando hay un bug, regresión o comportamiento roto; orquesta documentación, causa raíz, reproducción, fix plan aprobado, implementación y revisión.
---

# Bugs — driver de la rama BUG

> Esta skill es parte de SOOFT. Antes de usarla, seguí la skill `sooft` (principios, gates de aprobación, máquina de estados y reglas no negociables).

Este skill es un router de la rama `bug`. Conduce la máquina de estados de SOOFT y delega
cada paso a skills chicos.

- Fuente de verdad de estados: la skill `sooft` (§4 Máquina de estados).
- `type` en `.sooft/state.json`: `bug`.
- Regla de oro: no escribir código de fix hasta `phase == FIX_PLAN_APPROVED` o `IMPLEMENTING`.

## Ruta de skills

| Phase actual | Ejecutar | Output principal |
|---|---|---|
| `REQUIREMENT_LOADED` | recurso `internal/sooft-discovery.md` de `sooft` en modo bug | resumen de discovery |
| `REQUIREMENT_LOADED` tras discovery | documentar `BUG.md` desde el intake (template abajo) | `docs/bugs/{slug}/BUG.md` |
| `BUG_DOCUMENTED` | leé y seguí `assets/bug-analysis.md` | `ANALYSIS.md` |
| `BUG_ANALYZED` | leé y seguí `assets/bug-reproduction.md` | test rojo |
| `BUG_REPRODUCED` | leé y seguí `assets/fix-plan.md` | `FIX_PLAN.md` |
| `FIX_PLAN_REJECTED` | leé y seguí `assets/fix-plan.md` | `FIX_PLAN.md` corregido |
| `FIX_PLAN_APPROVED` / `IMPLEMENTING` | recurso `internal/sooft-implement-task.md` de `sooft` | fix/tests/evidencia + entradas en `.sooft/self-review-scratchpad.md` |
| `CODE_REVIEW_PENDING` | recurso `internal/sooft-code-review-gate.md` de `sooft` | aprobación humana con `docs/bugs/{slug}/SELF-REVIEW.md` como input |

`/review` conduce `IMPLEMENTING → VALIDATING → CODE_REVIEW_PENDING` y usa el recurso
`internal/sooft-validation.md` de `sooft`, cuyo **último paso** consolida el sketchpad de
autoevaluación en `docs/bugs/{slug}/SELF-REVIEW.md` siguiendo el template
`skills/sooft/assets/self-review-template.md`. Si aparecen hallazgos Very High/High, el flujo
pasa a `SECURITY_FINDINGS` y deriva al driver `sooft-security-remediation`.

Además, en **cada transición de fase** el agente mantiene `docs/bugs/{slug}/STATUS.md`
(snapshot semántico compacto rehidratable) actualizado in-place, junto con un snapshot rotativo
en `.sooft/status/YYYY-MM-DDTHH-MM.md`. Contrato: `skills/sooft/assets/status-template.md`.
Compaction manual on-demand: skill `sooft-checkpoint`.

## Worktree

```bash
git worktree add .worktrees/fix-{slug} -b fix/{slug}
```

Todo el trabajo ocurre en `.worktrees/fix-{slug}`.

## Intake → `BUG.md` (`BUG_DOCUMENTED`)

Tras el discovery en modo bug (comportamiento esperado vs actual, afectados, severidad,
entorno, ticket INC/RITM si hay), documentá `docs/bugs/{slug}/BUG.md`:

```
# BUG: {slug}

**Status:** Reportado | Analizando | Fix Planificado | Implementando | Resuelto

## Descripción
[Qué está roto en una oración]

## Pasos para reproducir
1. ...

## Comportamiento esperado
[Qué debería pasar]

## Comportamiento actual
[Qué está pasando]

## Contexto
- **Entorno:** dev | staging | producción
- **Versión/commit:** ...
- **Usuarios afectados:** ...
- **Severidad:** crítica | alta | media | baja
- **Ticket el issue tracker:** INC-XXXXX | N/A

## Logs / Evidencia
[Stack traces, logs relevantes, capturas]
```

`phase = BUG_DOCUMENTED`, `next_step = analyze`.

## Gates

- FIX_PLAN: frase canónica de `assets/fix-plan.md`.
- Código IA: frase canónica del recurso `internal/sooft-code-review-gate.md` de `sooft`.
- PR: no mergear hasta aprobación del developer/tech lead.

## Qué NO hacer

- No asumir causa raíz sin evidencia.
- No implementar antes del test de reproducción y fix plan aprobado.
- No ampliar scope más allá del bug.
- No crear estados que no estén en la máquina de estados de la skill `sooft`.
