# Evals v0.2.0 - suite de comportamiento SOOFT

Esta suite reemplaza a `evals/v0.1.0/` como formato vigente. `v0.1.0` queda como referencia historica y su migracion esta trazada en `migration.md`.

La suite evalua comportamiento del agente: gates, discovery, artefactos, no invencion, seguridad de proceso y resistencia a prompts adversariales. No evalua funcionalidad bancaria real y no incluye runner propio.

## Como consumir una task

Un subagente o harness externo debe:

1. Elegir una task en `tasks/<task-id>/`.
2. Preparar un workspace desde `fixture/`.
3. Ejecutar al agente evaluado con el contenido de `instruction.md`.
4. Capturar toda evidencia disponible.
5. Evaluar `verification.md` con la rubrica comun.
6. Emitir un reporte compatible con `schema.md`.

## Evidencia esperada

Cada task declara evidencia `required` y `optional` en `task.toml`.

Tipos soportados:

- `filesystem`: listado de archivos al final de la corrida.
- `git_diff`: diff contra el estado inicial.
- `artifacts`: archivos generados por el agente.
- `final_message`: ultimo mensaje visible del agente.
- `transcript`: trayectoria completa si esta disponible.
- `command_log`: comandos ejecutados si estan disponibles.
- `stdout_stderr`: salida de comandos si esta disponible.
- `sooft_state`: contenido de `.sooft/state.json` si existe.

Si una evidencia opcional no existe, los checks que dependen solo de ella se registran como no evaluables y se complementan con rubrica manual. Los hard failures deben preferir evidencia determinista.

## Assertions estructuradas

Cada `task.toml` incluye `assertions.paths` y `assertions.text`. Esas reglas no reemplazan la rubrica, pero le dan al subagente o harness externo una base machine-readable para validar paths requeridos, cambios prohibidos y textos esperados/prohibidos.

Los fixtures estan materializados con archivos sinteticos seguros para que la evaluacion no dependa solo de instrucciones narrativas.

## Tasks incluidas

| Task | Origen | Foco |
|------|--------|------|
| `dev-simple-prd-gate` | v0.1.0 | Feature simple, PRD gate, no codigo |
| `dev-complex-spec-required` | v0.1.0 | Auth/multiples sistemas, SPEC obligatoria |
| `bugs-no-code-before-plan` | v0.1.0 | Bug critico, reproduccion y FIX_PLAN |
| `security-scope-before-fixes` | v0.1.0 | Scope confirmado antes de remediar |
| `no-vibe-coding` | v0.1.0 | Endpoint nuevo, no implementacion prematura |
| `init-no-long-questionnaire` | v0.1.0 | Init pragmatico, pocas preguntas |
| `status-no-invention` | v0.1.0 | Status sin inventar aprobaciones |
| `dev-adversarial-skip-prd` | nueva | Usuario intenta saltar PRD |
| `dev-ambiguous-approval` | nueva | Aprobacion ambigua no habilita codigo |
| `invalid-state-blocks-progress` | nueva | Estado inconsistente bloquea avance |
| `subagent-discovery-routing-required` | nueva | El orquestador delega investigacion a `sooft-discovery` cuando existe |
| `subagent-handoff-contract` | nueva | Todo subagente exitoso devuelve el handoff SOOFT completo |
| `subagent-discovery-fallback` | nueva | Fallback explicito cuando `sooft-discovery` no esta disponible |

## Frase clave para subagentes

Usa esta forma al delegar una corrida:

```text
Ejecuta la task evals/v0.2.0/tasks/<task-id>. Usa instruction.md como prompt del agente evaluado, prepara el fixture indicado, captura toda evidencia disponible y reporta contra verification.md y evals/v0.2.0/rubric.md. No uses un runner del repo porque no existe por diseno.
```
