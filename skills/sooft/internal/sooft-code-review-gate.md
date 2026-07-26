# Recurso interno de `sooft`: code-review-gate

> Recurso interno de la constitución `sooft` — **no es una skill invocable** ni un slash command. Los routers lo cargan leyendo este archivo (`sooft/internal/sooft-code-review-gate.md`) cuando el flujo lo pide. Regí siempre por la skill `sooft` (principios, gates de aprobación, máquina de estados y reglas no negociables).

## Propósito

Asegurar que el código `[IA-generated]` sea revisado y aprobado por una persona antes de abrir PR.

## Cuándo usarlo

- `phase == CODE_REVIEW_PENDING`.

## Contexto: la sub-secuencia de `/review`

`/review` conduce `IMPLEMENTING → VALIDATING → CODE_REVIEW_PENDING` apoyándose en el recurso `internal/sooft-validation.md` de `sooft`:

1. `phase = VALIDATING`: corren tests, linter, el análisis de calidad y el SAST (los que el proyecto tenga configurados) + análisis del diff.
2. Si el SAST reporta hallazgos críticos/altos → `phase = SECURITY_FINDINGS`: **no se arma el PR**; derivar
   a la skill `sooft-security-remediation` o tramitar excepción con Ciberseguridad, y volver a `VALIDATING`.
3. Si los checks pasan → `phase = CODE_REVIEW_PENDING`: este gate.

## Entradas

- `.sooft/review.md` (resultado de `/review`).
- `.sooft/evidence.md`.
- **`docs/{tipo}/{slug}/SELF-REVIEW.md`** — autoevaluación consolidada del agente al final de `VALIDATING` (ver recurso `internal/sooft-validation.md`, sección "Consolidación de la autoevaluación", y el template `skills/sooft/assets/self-review-template.md`). **Bloqueante**: sin este artefacto completo y consistente, el gate 4 no se abre.
- Diff contra la rama target.
- Archivos marcados `[IA-generated]`.

## Delegación a subagentes Copilot CLI

Si estás en **Copilot CLI** y existen `sooft-code-reviewer` y/o `sooft-security-reviewer`, delegales una revisión read-only del diff antes de presentar este gate. Integrá sus hallazgos en `.sooft/review.md` o `.sooft/evidence.md`. Los subagentes no aprueban código IA-generated ni reemplazan la aprobación humana.

Si no están disponibles, seguí este recurso directamente.

## Flujo

0. **Pre-check de coherencia STATUS.md** (bloqueante): verificar que `docs/{tipo}/{slug}/STATUS.md` existe, tiene las 7 secciones obligatorias, `STATUS.md.phase == state.json.phase` (RF-05 anti-drift) y no contiene contenido prohibido de la lista negra RF-08 (PII, secretos, transcripts crudos, stack traces). Cualquier falla → HALT, no abrir el gate.
1. Listar archivos/bloques `[IA-generated]`.
2. Resumir resultado de `/review` y riesgos pendientes.
3. Presentar la autoevaluación `docs/{tipo}/{slug}/SELF-REVIEW.md` como input principal del review humano (ver checklist de review humano abajo).
4. Pedir aprobación humana explícita del código.
5. Si hay cambios pedidos, volver a `IMPLEMENTING`.
6. Registrar la evidencia en `.sooft/evidence.md` (siguiendo el recurso `internal/sooft-evidence.md` de `sooft`).

## Checklist de review humano (guía, no formulario)

El reviewer humano se apoya en la autoevaluación siguiendo estas cinco preguntas. El agente **no** completa esta checklist por el reviewer — la lista existe como guía compartida:

1. ¿La sección **"Cobertura"** cubre todas las tareas `[x]` del PLAN, cada una con su ID `[T0XX]`?
2. ¿Las **limitaciones** declaradas son aceptables para este alcance?
3. ¿Los **riesgos** declarados están mitigados o aceptados con justificación explícita?
4. ¿El **nivel de confianza** es consistente con las señales objetivas del reporte (tests, cobertura, lint, SAST)?
5. ¿Falta algún riesgo o limitación que el diff sugiere pero el SELF-REVIEW no captura?

## Transición

- Aprobado: `phase = REVIEW_DONE`, `last_step = approve-ia-code`, `next_step = open-pr`.
- Cambios pedidos: `phase = IMPLEMENTING`, `last_step = ia-code-changes-requested`, `next_step = implement`.

## Gate

**"El código IA-generated está marcado en <archivos>. Revisá el diff, `.sooft/review.md` y la autoevaluación en `docs/{tipo}/{slug}/SELF-REVIEW.md` antes de aprobarlo."**

Stop. No abrir PR hasta recibir aprobación explícita.

## Qué NO hacer

- No autoaprobar código generado por IA.
- No avanzar con hallazgos críticos abiertos.
- No ocultar archivos generados o modificados por IA.
- **No abrir el gate sin el `SELF-REVIEW.md` completo y consistente** (reglas en el recurso `internal/sooft-validation.md`, sección "Consolidación de la autoevaluación"). Un artefacto incompleto NO se acepta: se vuelve a `IMPLEMENTING` a cubrir la brecha o se documenta el desvío y se queda en `BLOCKED`.
- **No abrir el gate con `STATUS.md` ausente, incompleto o desincronizado de `state.json`** (RF-05 anti-drift). El pre-check del paso 0 es bloqueante.
- **No pushear la rama ni abrir el PR por iniciativa propia.** El push y la apertura del PR requieren
  confirmación explícita del developer (ver regla de transición §4.7 de `sooft`). PROHIBIDO `git push` en
  cualquier variante o `pull_request_create` sin que el developer lo pida o lo confirme. Sin ese OK, la
  rama queda local.
