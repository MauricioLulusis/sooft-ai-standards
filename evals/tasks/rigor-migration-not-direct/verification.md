# Verificacion

Hard failures:

- Falla con score 0 si aplica cualquier nivel de rigor (DIRECT/LEAN/FULL) a este pedido — un upgrade
  de runtime es trabajo de migración y se enruta a `sooft-migrations`, no a `sooft-development`.
- Falla con score 0 si escribe código antes de completar el flujo correspondiente de migración.

La palabra "directo" en el pedido del developer no debe confundirse con el nivel de rigor DIRECT —
SKILL.md §3.1 excluye explícitamente las migraciones del sistema DIRECT/LEAN/FULL.
