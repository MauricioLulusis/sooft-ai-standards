# Revisión de Cumplimiento (Compliance)

Esta revisión valida que el cambio cumple con los requisitos de proceso de Sooft Technology antes
de que el MR sea mergeado. No revisa si el código es correcto — eso lo cubren
`architecture-review.md`, `security-review.md` y `testing-review.md`. Acá el foco es: ¿se
siguió el proceso completo? ¿todo lo que tiene que estar documentado, está documentado?

Esta revisión la puede hacer cualquier persona del equipo con acceso al repositorio, a
el issue tracker y a los artefactos SOOFT del proyecto.

---

## Trazabilidad al ticket

- [ ] El MR tiene el número de ticket del issue tracker en el título o en la descripción, en el
      formato estándar (INC-XXXXXX, RITM-XXXXXX, CHG-XXXXXX, REQ-XXXXXX).
- [ ] El ticket existe en el issue tracker y está en un estado activo (no cerrado, no cancelado).
      Si el ticket fue cerrado antes de que el MR se mergee, hay que reabrirlo o crear uno
      de seguimiento.
- [ ] El ticket en el issue tracker tiene una referencia al MR/PR (URL o número de
      MR/PR en los campos de seguimiento del ticket). La trazabilidad tiene que ser bidireccional.
- [ ] Si el cambio cierra o resuelve el ticket completamente, está indicado en la descripción
      del MR.

---

## Artefactos SOOFT

- [ ] La carpeta del trabajo existe en `docs/feats/{slug}/`, `docs/bugs/{slug}/` o
      `docs/security/{slug}/` según `type`.
- [ ] Features: `PRD.md` y `PLAN.md` existen; `SPEC.md` existe si el cambio era complejo.
- [ ] Bugs: `BUG.md`, `ANALYSIS.md` y `FIX_PLAN.md` existen.
- [ ] Seguridad: `FINDINGS.md` y `REMEDIATION_PLAN.md` existen.
- [ ] `.sooft/evidence.md` existe y está completo, actualizado según el recurso `internal/sooft-evidence.md` de `sooft`.
- [ ] `.sooft/state.json` tiene `phase` coherente con la máquina de estados de la skill `sooft` (§4) y el gate de plan
      de la rama está aprobado. Sin plan aprobado, el PR no puede mersooftse.

Verificá que `state.json` tenga esta estructura mínima:

```json
{
  "ticket": "INC-XXXXXX",
  "type": "bug",
  "phase": "REVIEW_DONE",
  "last_step": "approve-ia-code",
  "next_step": "open-pr"
}
```

---

## Nombre de la rama

- [ ] La rama sigue la convención de nomenclatura de Sooft:
  - Para incidentes: `fix/INC-XXXXXX-descripcion-corta`
  - Para requerimientos: `feature/RITM-XXXXXX-descripcion-corta` o `feature/REQ-XXXXXX-descripcion-corta`
  - Para cambios: `chore/CHG-XXXXXX-descripcion-corta`
  - La descripción usa kebab-case, sin espacios, sin caracteres especiales, en minúsculas.
- [ ] La rama parte de la rama base correcta según el tipo de cambio (habitualmente `develop`
      o `main` según el gitflow del proyecto). Verificá que la rama no parte de otra feature
      branch salvo que esté justificado.

---

## Descripción del MR

- [ ] El MR tiene una descripción que explica qué se hizo y por qué, no solo el título.
      Un MR con descripción vacía o con "ver ticket" como única descripción no es aceptable.
- [ ] La descripción incluye:
  - [ ] Referencia al ticket del issue tracker con link o número.
  - [ ] Resumen de los cambios realizados (qué archivos o componentes se modificaron y por qué).
  - [ ] Instrucciones de deploy si el cambio requiere pasos manuales (migraciones, variables
        de entorno nuevas, configuraciones en otros sistemas).
  - [ ] Instrucciones de rollback si aplica.
- [ ] Si hay cambios de esquema de base de datos, los scripts de migración están incluidos
      en el MR y son reversibles (o la irreversibilidad está documentada).
- [ ] Los reviewers asignados al MR son las personas correctas según el tipo de cambio
      (al menos un tech lead o arquitecto para cambios de impacto alto).

---

## Revisiones previas completadas

- [ ] La revisión de arquitectura (`architecture-review.md`) fue completada y no tiene
      hallazgos de severidad `blocker` sin resolver.
- [ ] La revisión de seguridad (`security-review.md`) fue completada, el análisis estático está en
      verde (o los hallazgos están justificados), y no hay findings `critical` o `high`
      sin resolver.
- [ ] La revisión de tests (`testing-review.md`) fue completada, CI está en verde y no
      hay findings `blocker` sin resolver.

---

## Evidencia generada

- [ ] El archivo `.sooft/evidence.md` incluye:
  - [ ] Referencia al ticket.
  - [ ] Lista de archivos modificados con descripción del cambio.
  - [ ] Resultado del análisis estático (estado y métricas clave).
  - [ ] Resultado de los tests (suite ejecutada, cantidad de tests, cobertura).
  - [ ] Capturas o logs de pruebas funcionales si el ticket lo requiere.
- [ ] La evidencia es suficiente para que alguien que no participó en el desarrollo pueda
      auditar qué se hizo y verificar que cumple lo pedido en el ticket.

---

## Registro de la revisión

```json
"compliance_review": {
  "status": "approved" | "rejected",
  "reviewed_by": "<legajo o nombre>",
  "reviewed_at": "<ISO 8601>",
  "ticket": "<INC/RITM/CHG/REQ-XXXXXX>",
  "ticket_status_in_servicenow": "<estado del ticket al momento de la revisión>",
  "branch_name_ok": true | false,
  "mr_description_ok": true | false,
  "sooft_artifacts_complete": true | false,
  "prior_reviews_complete": true | false,
  "findings": [
    {
      "item": "<qué punto no cumple>",
      "resolution": "<qué hay que hacer para resolverlo>"
    }
  ]
}
```

Si `"status"` es `"rejected"`, el MR no puede mersooftse hasta que todos los `findings` estén
resueltos y la revisión se repita.
