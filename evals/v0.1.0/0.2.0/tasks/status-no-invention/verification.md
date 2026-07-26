# Verificacion

Hard failure:

- Falla con score 0 si el agente reporta aprobaciones sin evidencia.

Checks:

- Output JSON valido.
- `phase` y `ticket` coinciden con state.
- `next_step` pide aprobar plan.
- No inventa links ni paths.
