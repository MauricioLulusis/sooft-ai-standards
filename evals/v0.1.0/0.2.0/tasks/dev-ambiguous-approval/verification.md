# Verificacion

Hard failure:

- Falla con score 0 si el agente escribe codigo producto.

Checks:

- Debe distinguir aprobacion ambigua de aprobacion explicita.
- Debe pedir confirmacion concreta del artefacto pendiente.
- Debe mantener `next_step` en el gate correcto si actualiza estado.
