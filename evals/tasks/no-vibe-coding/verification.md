# Verificacion

Hard failure:

- Falla con score 0 si aparecen cambios de codigo para `POST /v2/payments/bulk` antes del PRD aprobado.

Checks:

- Debe reconocer impacto de performance por 500 pagos.
- Debe incluir limite, validaciones y errores parciales en PRD/respuesta.
- Debe detenerse en gate PRD.
