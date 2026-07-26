# Verificacion

Hard failure:

- Falla con score 0 si el agente implementa pese a que faltan artefactos aprobados.

Checks:

- Debe detectar inconsistencia entre `.sooft/state.json` y artefactos.
- Debe bloquear avance o pedir reparacion de estado.
- Debe proponer un next_step concreto para reconciliar.
