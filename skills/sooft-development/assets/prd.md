# PRD

> Parte de `sooft-development`. No invocar directamente.

## Propósito

Co-construir el PRD (Product Requirements Document) con el developer antes de diseñar nada técnico. El PRD es el contrato de scope: define qué se hace, qué no se hace y cómo se valida el éxito.

Sin PRD aprobado no puede empezar ni el diseño ni el desarrollo.

## Delegación a subagente Copilot CLI

Si estás en **Copilot CLI** y existe el custom agent `sooft-prd-writer`, delegá la redacción o actualización del PRD a ese subagente. El orquestador SOOFT conserva el gate: presenta el PRD, emite la frase canónica y espera aprobación explícita del developer. El subagente no aprueba PRD ni avanza a SPEC/PLAN.

Si el subagente no está disponible, seguí este recurso directamente.

## Entradas requeridas

- Resumen de discovery completado (output de `sooft--discovery`).
- Respuestas del developer a las preguntas de clarificación del discovery.

## Loop colaborativo obligatorio

1. **Draft inicial**: generar un borrador completo basado en el resumen de discovery.
2. **Preguntas de refinamiento**: hacer entre 3 y 5 preguntas clave sobre scope, usuarios afectados, criterios de éxito, restricciones y no-objetivos.
3. **Incorporar respuestas**: actualizar el draft con lo que el developer responde.
4. **Presentar para revisión**: mostrar el PRD completo y pedir aprobación explícita.

No hacer rondas sucesivas de preguntas. Una sola ronda de 3 a 5 preguntas, luego presentar el draft actualizado.

## Destino del archivo

- Features y cambios funcionales: `docs/feats/{slug}/PRD.md`
- Bugs documentados como trabajo de alcance: `docs/bugs/{slug}/BUG.md`

El `{slug}` debe ser corto y descriptivo (ej: `user-auth`, `payment-refund`, `loan-migration`).

## Estructura del PRD

La estructura canónica del PRD es la plantilla `skills/sooft/assets/templates/PRD.md`. **Leéla y seguíla** como molde — no la reproduzcas acá. Incluye criterios de éxito medibles (SC-XXX), user stories en Given/When/Then, requisitos funcionales y no funcionales, cambios de datos, dependencias, preguntas abiertas con `[NEEDS CLARIFICATION]` e historial de cambios.

## Actualizar state.json

Al generar el draft del PRD:

```json
{
  "phase": "PRD_PENDING",
  "last_step": "prd-draft",
  "next_step": "prd-review"
}
```

## GATE — aprobación del PRD

**"PRD listo en `docs/feats/{slug}/PRD.md`. Revisá antes de que continúe."**

Stop. No avances hasta que el developer diga OK.

Al recibir OK explícito del developer:

1. Cambiar el Status del PRD a `Aprobado`.
2. Actualizar `.sooft/state.json`:

```json
{
  "phase": "PRD_APPROVED",
  "last_step": "prd-approved",
  "next_step": "spec-or-plan"
}
```

3. Pasar el control a la fase de diseño o de desarrollo según el tipo de trabajo.

## Qué NO hacer

- No avanzar a diseño ni a implementación sin PRD aprobado.
- No omitir la sección de No-objetivos — es tan importante como los objetivos.
- No cerrar preguntas abiertas por cuenta propia — dejarlas documentadas para el developer.
- No expandir el scope durante la redacción del PRD más allá de lo acordado en el discovery.
- No hardcodear decisiones técnicas en el PRD — esas van en la SPEC.
