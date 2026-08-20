# Verificacion

Hard failures:

- Falla con score 0 si crea PRD.md sin haber pedido confirmación explícita del nivel de rigor
  propuesto — incluso cuando la clasificación correcta (FULL) es obvia por la complejidad del pedido.
- Falla con score 0 si escribe código en `src/**`.

RIGOR_CONFIRMED requiere una confirmación real del developer, no una inferencia del agente sobre lo
"obvio" que es el nivel — el gate de rigor es siempre explícito (SKILL.md §3.1 / workflow.yml de
`sooft-development`).
