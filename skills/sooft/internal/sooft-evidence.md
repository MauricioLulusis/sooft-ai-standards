# Recurso interno de `sooft`: evidence

> Recurso interno de la constitución `sooft` — **no es una skill invocable** ni un slash command. Las skills lo cargan leyendo este archivo (`sooft/internal/sooft-evidence.md`) cuando el flujo lo pide. Regí siempre por la skill `sooft` (principios, gates de aprobación, máquina de estados y reglas no negociables).

## Propósito

Mantener `.sooft/evidence.md` como registro auditable del trabajo y de las validaciones.

## Cuándo usarlo

- Al cerrar discovery, plan, implementación de tarea, reproducción de bug, fix, validación o review.
- Antes de abrir PR, para consolidar evidencia final.

## Entradas

- `.sooft/state.json`.
- Artefactos del ticket (`PRD.md`, `PLAN.md`, `BUG.md`, `FIX_PLAN.md`, `FINDINGS.md`, etc.).
- Salidas de tests, lint, análisis de calidad, SAST y `/review`.

## Delegación a subagente Copilot CLI

Si estás en **Copilot CLI** y existe el custom agent `sooft-evidence-writer`, delegá a ese subagente la actualización de `.sooft/evidence.md` y la consolidación de archivos modificados, validaciones y decisiones. El subagente no inventa resultados, no aprueba gates y no registra secretos ni PII. El orquestador conserva la transición de estado.

Si el subagente no está disponible, seguí este recurso directamente.

## Output

`.sooft/evidence.md` con ticket, branch, resumen, archivos modificados (marcando los
`[IA-generated]` y quién los revisó), decisiones, validaciones ejecutadas y próximos pasos.
Seguí el esqueleto de la plantilla canónica `skills/sooft/assets/templates/evidence.md`.

## Transición

Este skill no cambia `phase` por sí mismo. Solo actualiza evidencia y puede ajustar
`last_step` si el paso que lo invoca ya lo requiere.

## Qué NO hacer

- No inventar validaciones no ejecutadas.
- No registrar secretos ni PII.
- No usar evidencia como reemplazo de PRD, SPEC o PLAN.
