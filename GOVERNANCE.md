# GOVERNANCE.md

Define los controles, aprobaciones, trazabilidad y auditoría del uso de agentes de IA en el ciclo de desarrollo de Sooft Technology.

---

## Objetivo

Garantizar que el uso de IA en desarrollo sea:

- **Trazable**: cada acción queda registrada y asociada a un ticket
- **Auditable**: existe evidencia de qué hizo el agente y quién aprobó qué
- **Controlado**: los pasos críticos requieren aprobación humana
- **Seguro**: las restricciones de seguridad no son negociables
- **Repetible**: el proceso es consistente entre proyectos y equipos

---

## Principio base: Human in the Loop

El agente **asiste**, el developer **decide**.

Ningún cambio crítico se aplica sin revisión y aprobación humana explícita. El agente puede proponer, analizar, generar y revisar. La aprobación final siempre es del developer o del rol correspondiente.

---

## Controles obligatorios por fase

### Análisis de requerimiento
- [ ] Requerimiento asociado a ticket del issue tracker
- [ ] Ticket válido y activo
- [ ] Alcance definido
- [ ] Dudas abiertas identificadas y documentadas

### Especificación
- [ ] SPEC generada y guardada en `docs/feats/{slug}/SPEC.md` (si aplica)
- [ ] Criterios de aceptación definidos
- [ ] Casos borde documentados
- [ ] **Aprobación humana registrada**

### Plan técnico
- [ ] PLAN generado y guardado en `docs/feats/{slug}/PLAN.md`
- [ ] Componentes afectados identificados
- [ ] Riesgos técnicos documentados
- [ ] Si hay cambios de arquitectura: ADR generado
- [ ] **Aprobación humana registrada**

### Implementación
- [ ] Tareas derivadas del plan aprobado
- [ ] Tests incluidos o justificada su ausencia
- [ ] No se introdujeron secretos ni credenciales
- [ ] Análisis de calidad / SAST ejecutado (los que el proyecto tenga configurados)

### Revisión pre-PR
- [ ] Checklist de revisión completado (ver `skills/sooft/assets/reviews/`)
- [ ] Tests pasando
- [ ] Sin hallazgos críticos de seguridad
- [ ] Evidencia generada

### Cierre
- [ ] PR asociado al ticket
- [ ] Evidencia completa en `.sooft/evidence.md`
- [ ] Ticket actualizado en el issue tracker

---

## Aprobaciones requeridas

| Decisión | Quién aprueba |
|---|---|
| Especificación funcional | Developer + área funcional si aplica |
| Plan técnico | Tech lead o arquitecto |
| Cambios de arquitectura | Arquitectura |
| Cambios en seguridad o auth | Ciberseguridad |
| Cambios sobre datos sensibles o PII | Seguridad + DPO si aplica |
| Merge a main/develop | Tech lead |

---

## Evidencia mínima requerida

Cada ejecución del pipeline debe dejar como mínimo:

```
.sooft/
├── state.json       → estado del pipeline
├── config.json      → stack, integraciones y gates del proyecto
├── evidence.md      → registro completo de la sesión
└── discovery-checklist.json → ronda de discovery registrada

docs/feats/{slug}/   (o docs/bugs/{slug}/ · docs/security/{slug}/)
├── PRD.md           → requerimiento aprobado
├── SPEC.md          → diseño técnico aprobado (si aplica)
├── PLAN.md          → plan con tareas aprobado
├── STATUS.md        → snapshot semántico compacto, actualizado en cada transición de fase
└── SELF-REVIEW.md   → autoevaluación de código IA, input bloqueante del gate 4
```

El archivo `evidence.md` debe incluir:

- Ticket asociado
- Fecha y responsable
- Resumen de cambios
- Archivos modificados
- Validaciones ejecutadas y resultados
- Decisiones tomadas y su justificación
- Riesgos detectados
- Aprobaciones registradas
- Links a PR, pipeline y ticket

---

## Qué no puede hacer el agente sin aprobación explícita

- Implementar código sin spec aprobada
- Modificar arquitectura sin ADR
- Trabajar sobre datos sensibles sin revisión de seguridad
- Mergear a ramas principales
- Ejecutar comandos destructivos (drop, delete, truncate, etc.)
- Exponer o registrar información interna de Sooft

---

## Auditoría

Los siguientes artefactos son auditables:

- `AGENTS.md` — versión de reglas con la que trabajó el agente
- `.sooft/state.json` — trazabilidad del pipeline
- `.sooft/evidence.md` — registro de acciones y aprobaciones
- Historial de commits del MR/PR
- Resultados del análisis de calidad / SAST (si el proyecto los configura)

---

## Evolución de este documento

Este documento es versionado junto al repo.

Cambios en controles, aprobaciones o restricciones requieren:

1. MR con justificación
2. Revisión del equipo de AI Platform
3. Notificación a los equipos afectados
