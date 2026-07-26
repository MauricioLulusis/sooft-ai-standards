# Fix Plan

> Parte de `sooft-bugs`. No invocar directamente.

## Propósito

Definir el cambio mínimo para corregir un bug reproducido, con riesgos y validación, antes de tocar código de fix.

## Cuándo usarlo

- `phase == BUG_REPRODUCED`.
- `phase == FIX_PLAN_REJECTED`, para corregir el plan.

## Entradas

- `docs/bugs/{slug}/BUG.md`.
- `docs/bugs/{slug}/ANALYSIS.md`.
- El test rojo de reproducción.

## Delegación a subagente Copilot CLI

Si estás en **Copilot CLI** y existe el custom agent `sooft-bug-analyst`, delegá la síntesis de causa raíz, riesgos y enfoque mínimo del fix a ese subagente. Si el plan necesita estrategia de tests adicional, delegá esa parte a `sooft-test-strategist`. El orquestador `sooft-bugs` conserva el gate de FIX_PLAN y no permite escribir código de fix hasta aprobación explícita.

Si los subagentes no están disponibles, seguí este recurso directamente.

## Output

`docs/bugs/{slug}/FIX_PLAN.md`:

```
# FIX PLAN: {slug}

## Rama / worktree
fix/{slug} en .worktrees/fix-{slug}

## Causa raíz confirmada
[Una oración precisa]

## Enfoque del fix
[Descripción del cambio propuesto, sin código aún]

## Archivos afectados
- `path/exacto/al/archivo.java` — qué cambia

## Tests y validación
- [ ] Test de reproducción queda en verde
- [ ] Tests existentes no se rompen
- [ ] Validaciones de `sooft--validation` en verde

## Riesgos y efectos secundarios
[Qué puede romperse]

## Rollback
[Cómo revertir si el fix introduce problemas]
```

## Transición

- Al presentar: `phase = FIX_PLAN_PENDING`, `last_step = fix-plan`, `next_step = fix-plan-review`.
- Al aprobar: `phase = FIX_PLAN_APPROVED`, `last_step = fix-plan-approved`, `next_step = implement`.
- Al rechazar: `phase = FIX_PLAN_REJECTED`; corregir y volver a `FIX_PLAN_PENDING`.

## Gate

**"Fix plan listo en `docs/bugs/{slug}/FIX_PLAN.md`. Revisá antes de que empiece la corrección."**

Stop. No escribir código de fix hasta aprobación explícita.

## Qué NO hacer

- No planificar sin test de reproducción o bloqueo aprobado.
- No ampliar scope más allá del bug.
- No ocultar riesgos o efectos secundarios.
