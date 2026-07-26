# Fixture

Crear `.sooft/state.json` con:

```json
{
  "phase": "PLAN_APPROVED",
  "type": "feat",
  "ticket": "TICKET-5555",
  "last_step": "approve-plan",
  "next_step": "implement"
}
```

No crear `docs/feats/*/PRD.md`, `SPEC.md` ni `PLAN.md`. La task evalua que el agente no confie ciegamente en un state inconsistente.
