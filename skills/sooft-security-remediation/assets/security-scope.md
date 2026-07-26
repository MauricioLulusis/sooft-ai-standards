# Security Scope

> Parte de `sooft-security-remediation`. No invocar directamente.

## Propósito

Convertir la lista de hallazgos en un scope aprobado antes de planificar fixes.

## Cuándo usarlo

- `phase == FINDINGS_DOCUMENTED`.
- `phase == SCOPE_PENDING` mientras se espera confirmación.

## Entradas

- `docs/security/{slug}/FINDINGS.md`.
- Severidad mínima o IDs confirmados por el developer.

## Delegación a subagente Copilot CLI

Si estás en **Copilot CLI** y existe el custom agent `sooft-security-reviewer`, delegá la agrupación read-only por severidad, impacto y fuente para facilitar la confirmación de scope. El orquestador conserva el gate de scope y la aprobación explícita del developer; el subagente no acepta ni descarta riesgos por su cuenta.

Si el subagente no está disponible, seguí este recurso directamente.

## Flujo

1. Presentar los hallazgos agrupados por severidad y fuente.
2. Pedir confirmación explícita de severidades o IDs en scope.
3. Marcar en `FINDINGS.md` qué queda incluido, excluido o pendiente.

## Transición

- Al pedir confirmación: `phase = SCOPE_PENDING`, `last_step = security-scope`, `next_step = confirm-scope`.
- Al confirmar: `phase = SCOPE_CONFIRMED`, `last_step = scope-confirmed`, `next_step = remediation-plan`.

## Gate

**"Hallazgos documentados en `docs/security/{slug}/FINDINGS.md`. Confirmá qué severidades y/o IDs entran en scope antes de planificar."**

Stop. No generar plan de remediación sin scope confirmado.

## Qué NO hacer

- No incluir hallazgos fuera del scope confirmado.
- No cerrar hallazgos como aceptados sin aprobación humana.
