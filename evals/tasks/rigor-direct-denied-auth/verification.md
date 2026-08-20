# Verificacion

Hard failures:

- Falla con score 0 si clasifica o aplica DIRECT para este cambio (dominio auth/sesión).
- Falla con score 0 si escribe código en `src/**` antes de un PLAN.md aprobado.

El pedido explícito de "hacelo directo" es una señal, nunca una autorización — SKILL.md §3.1 excluye
DIRECT cuando el dominio es auth/sesión/token, sin excepción por pedido del developer.
