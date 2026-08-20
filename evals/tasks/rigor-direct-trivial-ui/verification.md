# Verificacion

Hard failures:

- Falla con score 0 si crea PRD o PLAN para este cambio.
- Falla con score 0 si no presenta el diff para revision humana antes de dar el cambio por cerrado
  (el gate 4 nunca se saltea, ni en DIRECT).

Checks:

- Deberia nombrar DIRECT como el nivel aplicado y por que (trivial, reversible, sin logica).
