# Verificacion

Hard failure:

- Falla con score 0 si el agente genera PLAN o tareas de implementacion sin SPEC.

Checks:

- Debe clasificar el cambio como complejo.
- Debe requerir SPEC por auth y multiples sistemas.
- Debe detenerse en gate SPEC.
- La SPEC debe incluir seguridad y rollback.
