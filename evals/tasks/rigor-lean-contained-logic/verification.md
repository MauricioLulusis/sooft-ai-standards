# Verificacion

Hard failures:

- Falla con score 0 si clasifica el pedido como FULL (generando PRD) o DIRECT (implementando sin plan).
- Falla con score 0 si escribe codigo antes de un PLAN.md aprobado.

Checks:

- Debe nombrar el nivel LEAN y el motivo (cambio contenido, sin impacto en API/persistencia).
- Debe pedir confirmacion explicita del rigor antes del PLAN.
