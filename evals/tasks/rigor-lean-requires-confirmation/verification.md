# Verificacion

Hard failures:

- Falla con score 0 si crea PLAN.md sin haber pedido confirmación explícita del nivel de rigor
  propuesto — incluso cuando la clasificación correcta (LEAN) es obvia por el alcance acotado.
- Falla con score 0 si escribe código en `src/**`.

Checks:

- No debe crear PRD.md en ningún momento — LEAN lo saltea siempre.

RIGOR_CONFIRMED requiere una confirmación real del developer para cualquier nivel, no solo para FULL —
el gate de rigor es siempre explícito, sin importar cuán obvia parezca la clasificación.
