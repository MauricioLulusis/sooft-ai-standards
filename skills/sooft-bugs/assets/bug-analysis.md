# Bug Analysis

> Parte de `sooft-bugs`. No invocar directamente.

## Propósito

Encontrar y documentar la causa raíz de un bug antes de escribir el test de reproducción o el fix.

## Cuándo usarlo

- `phase == BUG_DOCUMENTED`.
- `phase == BLOCKED` vuelve a `BUG_DOCUMENTED` tras resolver la dependencia.

## Entradas

- `docs/bugs/{slug}/BUG.md`.
- Logs, stack traces, pasos de reproducción y contexto del ticket.
- Código relevante, leído solo después del discovery obligatorio.

## Delegación a subagente Copilot CLI

Si estás en **Copilot CLI** y existe el custom agent `sooft-bug-analyst`, delegá a ese subagente el análisis read-only de causa raíz, evidencia y camino de reproducción. El orquestador `sooft-bugs` conserva `.sooft/state.json`, decide si la causa está confirmada y no permite fix sin reproducción/plan aprobado.

Si el subagente no está disponible, seguí este recurso directamente.

## Output

`docs/bugs/{slug}/ANALYSIS.md`:

```
# ANALYSIS: {slug}

## Causa raíz
**Estado:** confirmada | sospechada
[Descripción de la causa raíz]

## Evidencia
[Qué código, log o comportamiento confirma o sugiere la causa]

## Código afectado
- `path/al/archivo.java` — líneas X-Y

## Impacto
[Qué funcionalidad, datos o usuarios están afectados]

## Camino de reproducción
[Del entry point hasta el fallo]

## Dudas abiertas
[Preguntas sin respuesta que pueden afectar el fix]
```

No tratar causa sospechada como confirmada sin evidencia. Si hay dudas, documentarlas y
consultarlas con el developer.

## Transición

`phase = BUG_ANALYZED`, `last_step = bug-analysis`, `next_step = reproduce`.

## Qué NO hacer

- No presentar una hipótesis como causa confirmada sin evidencia.
- No proponer el fix todavía.
- No avanzar si las dudas abiertas cambian el approach del fix.
