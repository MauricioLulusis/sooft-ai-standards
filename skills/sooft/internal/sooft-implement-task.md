# Recurso interno de `sooft`: implement-task

> Recurso interno de la constitución `sooft` — **no es una skill invocable** ni un slash command. Los routers lo cargan leyendo este archivo (`sooft/internal/sooft-implement-task.md`) cuando el flujo lo pide. Regí siempre por la skill `sooft` (principios, gates de aprobación, máquina de estados y reglas no negociables).

## Propósito

Ejecutar exactamente una tarea aprobada y registrar progreso sin rediseñar el scope.

## Cuándo usarlo

- `phase == PLAN_APPROVED`, `FIX_PLAN_APPROVED` o `REMEDIATION_PLAN_APPROVED`.
- `phase == IMPLEMENTING` para continuar la próxima tarea pendiente.

## Entradas

- Feature: `docs/feats/{slug}/PLAN.md`.
- Bug: `docs/bugs/{slug}/FIX_PLAN.md`.
- Security: `docs/security/{slug}/REMEDIATION_PLAN.md`.
- Las reglas no negociables de la skill `sooft` (§6).

## Antes de la primera tarea

Corré la verificación de consistencia del pie del plan: cada tarea se rastrea a un requisito,
los criterios de éxito tienen tarea de validación, y no queda ningún `[NEEDS CLARIFICATION]`
abierto. Si algo no cierra, pará y resolvelo con el developer.

## Flujo

1. Leer el plan aprobado y elegir la primera tarea pendiente.
2. Verificar consistencia: requisito cubierto, sin `[NEEDS CLARIFICATION]`, paths concretos.
3. Implementar **solo** lo indicado por la tarea. Una tarea a la vez.
4. Ejecutar la validación mínima de esa tarea; en TDD confirmar rojo antes de verde (ver abajo).
5. Marcar la tarea `[x]` en el plan, actualizar `.sooft/evidence.md` siguiendo el recurso `internal/sooft-evidence.md` de `sooft`, y **anotar la entrada correspondiente en el sketchpad de autoevaluación `.sooft/self-review-scratchpad.md`** (ver "Sketchpad de autoevaluación" abajo).
6. Actualizar `STATUS.md` versionado y escribir snapshot rotativo (ver "Compaction del snapshot de estado" abajo). Si la tarea completada dispara una transición de fase, el snapshot correspondiente se marca como snapshot de gate y se mueve a `.sooft/status/gates/`.
7. Si era la primera tarea, pasar a `phase = IMPLEMENTING`.

### Sketchpad de autoevaluación

Durante `IMPLEMENTING` el agente mantiene `.sooft/self-review-scratchpad.md` como working memory. Es la fuente única que se consolida en el `SELF-REVIEW.md` final al terminar `VALIDATING` (ver recurso `internal/sooft-validation.md` de `sooft`).

Cada vez que se marca una tarea `[x]` (paso 5) también se agrega un bloque al sketchpad con cuatro campos por tarea: **implementado**, **validado manualmente**, **edge cases fuera** y **decisiones heurísticas / atajos**. Estructura y formato exacto: `skills/sooft/assets/self-review-sketchpad-template.md`.

Reglas mínimas:

- El sketchpad no se commitea — vive en `.sooft/`, cubierto por el `.gitignore` del proyecto.
- Un bloque por tarea del PLAN, identificado por `[T0XX]`.
- Notas breves. Es memoria de trabajo, no un artefacto de review.
- Se congela al pasar a `VALIDATING`; si tras el gate 4 el flujo vuelve a `IMPLEMENTING`, se retoma agregando entradas nuevas (no se re-escriben las viejas).

### Compaction del snapshot de estado

Después de actualizar `evidence.md` y el sketchpad (paso 5), el agente actualiza el snapshot semántico del proyecto:

1. **STATUS.md versionado** (`docs/{tipo}/{slug}/STATUS.md`): actualización **in-place** (no crece histórico). Refrescar Metadatos, agregar decisiones nuevas de `evidence.md` desde el último update, sincronizar la checklist de "Progreso del PLAN" con las tareas marcadas `[x]`, archivar riesgos cerrados. Si el archivo no existe, generarlo desde `skills/sooft/assets/status-template.md`.
2. **Snapshot rotativo** (`.sooft/status/YYYY-MM-DDTHH-MM.md`): copia del STATUS.md actualizado. Formato Windows-friendly (sin `:`).
3. **Retención FIFO=10**: eliminar los snapshots más viejos si exceden. Configurable con `status_retention` en `.sooft/config.json`.
4. **Snapshots de gates aprobados**: si el paso 5 disparó una transición a un estado post-gate (`PRD_APPROVED`, `SPEC_APPROVED`, `PLAN_APPROVED`, `FIX_PLAN_APPROVED`, `REMEDIATION_PLAN_APPROVED`, `MIGRATION_PLAN_APPROVED`, `REVIEW_DONE`), mover el snapshot recién creado a `.sooft/status/gates/{gate}-approved-YYYY-MM-DD.md`. Estos **no rotan**.
5. **Anti-drift (RF-05)**: verificar que `STATUS.md.phase == state.json.phase`. Divergencia → HALT y reporte al developer.
6. **Contenido prohibido**: sin PII, secretos, transcripts crudos, stack traces. Ver contrato completo en `skills/sooft/assets/status-template.md`.

Este paso es **transversal** y no cambia la máquina de estados. Un fallo en la compaction no bloquea la tarea, pero se registra en `evidence.md` como incidencia a resolver antes del gate 4.

### TDD para lógica nueva (solo features)

Por cada unidad de lógica nueva del plan (lógica de negocio, validaciones, cálculos, endpoints
nuevos, parsers/regex) aplicá el ciclo **test primero → rojo → verde → refactor**: escribí el
test PRIMERO y confirmá que FALLA (rojo), implementá el mínimo para que pase (verde), y recién
después refactorizá manteniendo el test en verde. Ubicá cada test en la **ruta REAL** fijada en
el plan. Corré la suite del stack (JUnit/xUnit/pytest/Jest) tras cada unidad. Aplica **solo a
lógica nueva (features)**: NO a fixes (los bugs llevan su test de reproducción-first), ni a
refactors/chores. Detalle: la skill `sooft` (§6.2 Testing y TDD).

### Reglas de Sooft (no negociables)

Arquitectura en capas (controller → service → repository), sin secretos hardcodeados, sin PII
en logs, menor privilegio, validar todo input externo — ver la skill `sooft` (§6).

### Trazabilidad IA

Marcar todo bloque generado con `// [IA-generated] SOOFT — revisar antes de mersooft. Ticket: <TICKET-XXXXX>`
(ajustando el comentario al lenguaje) y registrar los archivos para la evidencia — ver la skill
`sooft` (§6.4 Trazabilidad del código IA).

### Desvíos

Si surge algo no contemplado, **pausar** y describir el desvío antes de continuar; actualizar el
plan solo para marcar avance o registrar un desvío aprobado.

## Transición

- Al iniciar: `phase = IMPLEMENTING`, `last_step = start-implementation`.
- Mientras queden tareas: `next_step = implement-next-task`.
- Al completar todas: `next_step = validate`.

## Qué NO hacer

- No ejecutar tareas sin plan aprobado.
- No hacer refactors oportunistas.
- No seguir si un test requerido falla.
- No modificar el plan salvo para marcar avance o registrar un desvío aprobado.
