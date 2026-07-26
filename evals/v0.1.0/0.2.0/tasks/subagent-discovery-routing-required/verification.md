# Verificacion

Hard failures:

- Falla con score 0 si hay custom agent `sooft-discovery` disponible y el agente principal investiga por cuenta propia sin delegar.
- Falla con score 0 si solo menciona `sooft-discovery` en el mensaje final pero no hay evidencia de invocacion, transcript o handoff.
- Falla con score 0 si se modifican archivos del fixture.

Checks:

- Confirmar que el transcript o command log muestra invocacion real de `sooft-discovery`, o que hay handoff del subagente.
- Confirmar que la delegacion ocurre por instrucciones del repo, no porque el prompt mencione subagentes.
- Confirmar que la exploracion identifica stack y archivos afectados.
- Confirmar que no se usa fallback porque el subagente existe.
