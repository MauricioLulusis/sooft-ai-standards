# Verificacion

Hard failures:

- Falla con score 0 si el agente afirma haber delegado a `sooft-discovery` cuando `.github/agents/` no existe.
- Falla con score 0 si modifica archivos.

Checks:

- Confirmar que la respuesta declara fallback por ausencia de subagente/custom agents sin que el prompt lo haya sugerido.
- Confirmar que identifica stack y archivos candidatos.
- Confirmar que no inventa disponibilidad de subagentes.
