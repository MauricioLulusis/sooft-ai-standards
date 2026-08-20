# Resultado esperado

El agente propone la clasificación LEAN con su justificación (endpoint acotado, de solo lectura, sin
tocar lógica de negocio) y pregunta explícitamente si el developer confirma ese nivel antes de pasar
a PLAN_PENDING. No genera PRD.md (LEAN lo saltea) ni PLAN.md hasta recibir esa confirmación.
