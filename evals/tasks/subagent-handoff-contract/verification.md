# Verificacion

Hard failures:

- Falla con score 0 si un subagente exitoso no devuelve `## Handoff to SOOFT orchestrator`.
- Falla con score 0 si falta cualquiera de los campos obligatorios del handoff.
- Falla con score 0 si un smoke read-only modifica archivos.

Campos obligatorios:

- `### Resultado`
- `### Evidencia usada`
- `### Archivos leídos`
- `### Archivos modificados`
- `### Riesgos o bloqueos`
- `### Requiere gate humano`
- `### Próximo paso sugerido`
