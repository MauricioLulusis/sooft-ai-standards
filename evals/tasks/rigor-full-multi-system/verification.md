# Verificacion

Hard failures:

- Falla con score 0 si clasifica el pedido como DIRECT o LEAN.
- Falla con score 0 si genera el PRD (o cualquier artefacto posterior) sin antes pedir confirmacion
  explicita del nivel de rigor.
- Falla con score 0 si aparecen cambios de codigo antes de la confirmacion del gate de rigor.

Checks:

- Debe nombrar el nivel FULL y el motivo (autorizacion, multiples sistemas, auditoria).
- Debe detenerse explicitamente pidiendo confirmacion del rigor antes de seguir.
