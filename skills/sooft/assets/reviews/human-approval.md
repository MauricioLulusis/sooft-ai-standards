# Aprobación Humana en el Pipeline SOOFT

Las aprobaciones humanas son puntos de control obligatorios antes de que el pipeline avance.
El flujo SOOFT puede pedir aprobación de PRD, SPEC, plan de la rama y código `[IA-generated]`.
Sin el gate correspondiente aprobado en `.sooft/state.json`, los pasos siguientes no deben ejecutarse.

Este documento define qué revisar en cada instancia y cómo registrar la decisión.

---

## 1. Aprobación de Spec (`SPEC_PENDING`)

El archivo a revisar es `docs/feats/{slug}/SPEC.md`, generado por `sooft-technical-spec`.

### Qué validar

**Alineación con el ticket**

- [ ] El número de ticket mencionado en la spec (INC/RITM/CHG/REQ) coincide con el ticket real en el issue tracker.
- [ ] El problema descripto en la spec es el mismo que describe el ticket, no una interpretación
      diferente.
- [ ] Si el ticket tiene criterios de aceptación explícitos, todos están contemplados en la spec.
      Si alguno falta, es un bloqueante.

**Alcance**

- [ ] El alcance está definido con precisión: qué entra y qué no entra en este cambio.
- [ ] No hay funcionalidad extra que el ticket no haya pedido (scope creep).
- [ ] Los sistemas afectados están listados. Si se menciona un sistema que no debería estar
      involucrado, investigá por qué.

**Requisitos funcionales**

- [ ] Cada requisito funcional es verificable: podés escribir un caso de prueba concreto para él.
      Si un requisito dice "la respuesta debe ser rápida", eso no es verificable — tiene que decir
      "la respuesta debe ser menor a 500ms bajo carga de X requests/seg".
- [ ] Los flujos principales (happy path) están descriptos paso a paso.
- [ ] Los flujos alternativos y de error están identificados (qué pasa si el input es inválido,
      si un servicio externo no responde, etc.).

**Requisitos no funcionales**

- [ ] Se especifica el SLA o tiempo de respuesta esperado si el ticket lo implica.
- [ ] Se indica si hay restricciones de disponibilidad (ej: ventana de mantenimiento, impacto
      en producción fuera de horario).
- [ ] Se menciona si hay restricciones de seguridad o datos sensibles involucrados.

**Claridad**

- [ ] La spec está escrita de forma que alguien del equipo que no participó en el análisis la
      entiende sin necesidad de contexto adicional.
- [ ] No hay términos ambiguos sin definir ("debería", "a veces", "en la mayoría de los casos").

### Cómo registrar la aprobación

Cuando la spec está aprobada, actualizá `.sooft/state.json` con:

```json
{
  "phase": "SPEC_APPROVED",
  "last_step": "spec-approved",
  "next_step": "plan"
}
```

Si la spec requiere correcciones antes de aprobarse, pasar a `SPEC_REJECTED` y detallar
exactamente qué tiene que corregirse.

---

## 2. Aprobación de Plan (`PLAN_PENDING`, `FIX_PLAN_PENDING`, `REMEDIATION_PLAN_PENDING`)

El archivo a revisar depende de la rama:

- Feature: `docs/feats/{slug}/PLAN.md`, generado por `sooft-implementation-plan`.
- Bug: `docs/bugs/{slug}/FIX_PLAN.md`, generado por `sooft-fix-plan`.
- Seguridad: `docs/security/{slug}/REMEDIATION_PLAN.md`, generado por `sooft-remediation-plan`.

### Qué validar

**Consistencia con la spec aprobada**

- [ ] Cada requisito funcional de la spec tiene una o más tareas en el plan que lo atienden.
      Si encontrás un requisito sin cobertura en el plan, es un bloqueante.
- [ ] El plan no incluye trabajo que la spec no contempla. Si aparece algo nuevo, evaluá si
      es una dependencia técnica necesaria o es scope creep que hay que sacar.

**Factibilidad técnica**

- [ ] El approach técnico propuesto es compatible con la arquitectura actual del sistema afectado.
      Si el plan propone, por ejemplo, agregar una dependencia nueva, confirmá que está alineado
      con los estándares de Sooft.
- [ ] Las tareas tienen un tamaño razonable: ninguna tarea debería tomar más de un día sin
      que esté justificado. Si una tarea es muy grande, hay que subdividirla antes de aprobar.
- [ ] Las dependencias entre tareas están identificadas. Si la tarea 3 depende de la tarea 1,
      eso tiene que estar explícito.

**Riesgos**

- [ ] Los riesgos identificados en el plan son reales y tienen mitigación propuesta.
- [ ] Si hay cambios que afectan a otros equipos (APIs compartidas, base de datos compartida,
      contratos de integración), el plan indica cómo se coordina eso.
- [ ] Si el cambio requiere deploy coordinado con otro sistema, está indicado.

**Estimación**

- [ ] La estimación total del plan es coherente con la urgencia del ticket (ej: un INC crítico
      no puede tener un plan de dos semanas sin justificación).
- [ ] Si la estimación supera lo esperado, hay que comunicarlo al responsable del ticket antes
      de avanzar.

**Estrategia de rollback**

- [ ] El plan menciona cómo se revierte el cambio si falla en producción.
- [ ] Si no hay estrategia de rollback posible (ej: migraciones de datos destructivas), eso
      está documentado y aceptado explícitamente.

### Cómo registrar la aprobación

Cuando el plan está aprobado, actualizá `.sooft/state.json` con el estado aprobado de la rama:

```json
{
  "phase": "PLAN_APPROVED | FIX_PLAN_APPROVED | REMEDIATION_PLAN_APPROVED",
  "last_step": "plan-approved",
  "next_step": "implement"
}
```

Si necesitás correcciones, usá el estado rechazado de la rama (`PLAN_REJECTED`,
`FIX_PLAN_REJECTED` o `REMEDIATION_PLAN_REJECTED`) y registrá los comentarios en el artefacto
o en `.sooft/evidence.md`.

---

## Reglas generales de las aprobaciones

- Las aprobaciones no son automáticas. Tienen que ser hechas por una persona con contexto
  suficiente del cambio (el tech lead del equipo o quien corresponda según el tipo de ticket).
- Una aprobación registrada implica responsabilidad sobre lo revisado. No aprobés si no
  revisaste el artefacto completo.
- Si encontrás un error después de haber aprobado, volvé al estado rechazado correspondiente,
  corregí el artefacto y presentalo de nuevo. No continúes el pipeline con artefactos inconsistentes.
- Cuando se registre metadata de aprobación, `approved_by` y `approved_at` no pueden quedar vacíos.
