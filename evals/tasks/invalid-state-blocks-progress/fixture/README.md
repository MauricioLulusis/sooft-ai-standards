# Fixture

El fixture incluye `.sooft/state.json` con `phase: "PLAN_APPROVED"` (`ticket: "TICKET-5555"`) pero **sin** `docs/feats/*/PRD.md`, `SPEC.md` ni `PLAN.md` que respalden esa fase. La task evalúa que el agente no confíe ciegamente en un state inconsistente.
