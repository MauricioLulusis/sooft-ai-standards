# Template — Sketchpad de autoevaluación (`.sooft/self-review-scratchpad.md`)

> Recurso interno de la constitución `sooft`. Working memory del agente durante `IMPLEMENTING`. Alimenta la consolidación final en `SELF-REVIEW.md` (ver `skills/sooft/assets/self-review-template.md`). No se commitea (queda cubierto por el `.gitignore` de `.sooft/`).

## Cuándo se usa

Con `phase == IMPLEMENTING`. El agente añade una entrada por cada tarea del PLAN completada, antes o al mismo tiempo que marca la tarea `[x]` y actualiza `.sooft/evidence.md`. La estructura es intencionalmente laxa: es memoria de trabajo, no un artefacto de review.

## Reglas

- **Un bloque por tarea `[T0XX]`.** Sin excepciones.
- **Notas breves**. Frases sueltas, viñetas. No prosa larga.
- **Muta libre**. Se puede corregir/borrar/renombrar mientras el trabajo esté en `IMPLEMENTING`.
- **Al pasar a `VALIDATING`, congelar**. La consolidación lee este archivo como fuente única.
- **Si el gate 4 rechaza y vuelve a `IMPLEMENTING`**, retomar el sketchpad y agregar entradas nuevas para los cambios; NO re-escribir las viejas.

## Template

Copiar al archivo `.sooft/self-review-scratchpad.md` y completar por cada tarea completada.

```markdown
# Sketchpad de autoevaluación — <slug>

- **Ticket:** <STRY-XXXXXXX / N/A>
- **Type:** <feat | bug | security>
- **PLAN:** <path al PLAN.md correspondiente>

---

## [T001] — <título breve de la tarea>

**Implementado:**
- <bullet>

**Validado manualmente:**
- <bullet>

**Edge cases fuera:**
- <bullet o "ninguno pertinente" con motivo>

**Decisiones heurísticas / atajos:**
- <bullet o "ninguna">

**Notas para el SELF-REVIEW final:**
- <lo que quiero recordar cuando consolide>

---

## [T002] — <título breve>

**Implementado:**
- ...

**Validado manualmente:**
- ...

**Edge cases fuera:**
- ...

**Decisiones heurísticas / atajos:**
- ...

**Notas para el SELF-REVIEW final:**
- ...
```

## Historial

| Fecha | Autor | Cambio |
|---|---|---|
| 2026-07-03 | SOOFT (TICKET-2045) | Template inicial. |
