Ejecutá smoke tests de los custom agents SOOFT disponibles en `.github/agents/` con prompts read-only. Para cada subagente exitoso, capturá la respuesta y verificá que incluya `## Handoff to SOOFT orchestrator` con todos los campos obligatorios.

No edites archivos. Reportá una tabla con cada subagente, exit code, si modificó archivos y si cumplió el contrato de handoff.
