# Bug Reproduction

> Parte de `sooft-bugs`. No invocar directamente.

## Propósito

Crear una prueba de regresión que falle por el bug actual y pueda quedar verde después del fix.

## Cuándo usarlo

- `phase == BUG_ANALYZED`.

## Entradas

- `docs/bugs/{slug}/BUG.md`.
- `docs/bugs/{slug}/ANALYSIS.md`.
- La convención de tests existente del proyecto (ver el recurso `internal/sooft-test-strategy.md` de `sooft`).

## Delegación a subagentes Copilot CLI

Si estás en **Copilot CLI** y existen custom agents:

- Usá `sooft-bug-analyst` para precisar el camino de reproducción y comandos diagnósticos.
- Usá `sooft-test-strategist` para ubicar la convención real de tests y proponer el test rojo.

El orquestador `sooft-bugs` conserva la transición a `BUG_REPRODUCED`, valida que el fallo sea por el bug reportado y no implementa el fix en este paso.

Si los subagentes no están disponibles, seguí este recurso directamente.

## Flujo

1. Descubrir framework, runner y ubicación real de tests (no inventar la ruta).
2. Escribir el test mínimo que reproduce el comportamiento roto.
3. Ejecutar solo el test o suite relevante.
4. Confirmar que falla por el comportamiento reportado (rojo).
5. Commitear el test como evidencia: `test({slug}): reproducción del bug — falla en estado actual`.
6. Registrar resultado en `ANALYSIS.md` y `.sooft/evidence.md` (usando `sooft--evidence`).

Si no se puede reproducir en test: documentar por qué en `ANALYSIS.md` y consultarlo con el
developer antes de continuar. No avanzar hasta tener respuesta.

## Transición

`phase = BUG_REPRODUCED`, `last_step = bug-reproduction`, `next_step = fix-plan`.

## Qué NO hacer

- No implementar el fix en este paso.
- No aceptar un test que falla por setup roto o expectativa incorrecta.
- No avanzar si el bug no se puede reproducir sin documentar el bloqueo.
