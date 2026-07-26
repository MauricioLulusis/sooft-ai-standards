# Remediation Plan

> Parte de `sooft-security-remediation`. No invocar directamente.

## Propósito

Planificar fixes de seguridad aprobados en scope antes de aplicarlos.

## Cuándo usarlo

- `phase == SCOPE_CONFIRMED`.
- `phase == REMEDIATION_PLAN_REJECTED`, para corregir el plan.

## Entradas

- `docs/security/{slug}/FINDINGS.md` con scope confirmado.
- Las reglas de seguridad de la skill `sooft` (§6 Reglas no negociables).

## Delegación a subagente Copilot CLI

Si estás en **Copilot CLI** y existe el custom agent `sooft-security-reviewer`, delegá la revisión del approach de remediación, riesgos y validaciones de seguridad a ese subagente. El orquestador `sooft-security-remediation` conserva el gate de REMEDIATION_PLAN y no permite aplicar fixes hasta aprobación explícita.

Si el subagente no está disponible, seguí este recurso directamente.

## Output

`docs/security/{slug}/REMEDIATION_PLAN.md`. Solo para los hallazgos confirmados en scope:

```
## Scope confirmado
Lista de IDs de hallazgos incluidos.

## Fixes planificados
Para cada hallazgo en scope:
- ID y descripción
- Approach de fix (qué cambiar, qué no cambiar)
- Archivos afectados (paths exactos)
- Orden de aplicación
- Riesgos y efectos secundarios posibles
- Validación post-fix

## Nota sobre cambios en auth/autorización
Si algún fix modifica lógica de autenticación o autorización: indicar explícitamente que
requiere revisión de Ciberseguridad antes de mergear.
```

## Transición

- Al presentar: `phase = REMEDIATION_PLAN_PENDING`, `last_step = remediation-plan`, `next_step = remediation-plan-review`.
- Al aprobar: `phase = REMEDIATION_PLAN_APPROVED`, `last_step = remediation-plan-approved`, `next_step = implement`.
- Al rechazar: `phase = REMEDIATION_PLAN_REJECTED`; corregir y volver a `REMEDIATION_PLAN_PENDING`.

## Gate

**"Plan de remediación listo en `docs/security/{slug}/REMEDIATION_PLAN.md`. Revisá approach, archivos y riesgos antes de aplicar fixes."**

Stop. No aplicar fixes hasta aprobación explícita.

## Qué NO hacer

- No planificar findings fuera de scope.
- No mezclar remediación con refactors.
- No debilitar seguridad como workaround.
