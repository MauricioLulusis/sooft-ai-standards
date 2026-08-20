---
name: sooft-incident-response
description: Usar cuando hay un incidente en producción (INC en el issue tracker) que requiere análisis y corrección urgente.
---

# Incident Response — flujo de hotfix urgente

> Esta skill es parte de SOOFT. Antes de usarla, seguí la skill `sooft` (principios, gates de aprobación, máquina de estados y reglas no negociables).

> **Proyección estructurada:** la secuencia de este flujo también vive en `workflow.yml` (mismo
> directorio) — formato declarativo, agnóstico a la herramienta. Marca explícitamente que este
> skill NO usa la máquina de estados compartida (`uses_shared_state_machine: false`).

## Cuándo usarlo

Cuando hay un INC activo en producción que requiere acción urgente. Este flujo es **abreviado y NO usa la máquina de estados de `sooft`**: no setea `type` en `.sooft/state.json` ni recorre los gates PRD/SPEC/PLAN. El único gate obligatorio es el del paso 4 (aprobación del tech lead antes de tocar producción).

## Diferencia con bugs

| Aspecto | Bug (desarrollo) | Incidente (operación) |
|---|---|---|
| Urgencia | Normal | Alta / Crítica |
| Entorno afectado | No-productivo | Producción |
| Flujo | Completo (PRD, SPEC, PLAN) | Abreviado |
| Rama | fix/{slug} | hot-fix/{slug} |
| Deploy | Ciclo normal | Puede ir directo a producción |
| Post-mortem | No requerido | Requerido para P1/P2 |

## Severidades

- **P1 — Crítico**: servicio caído o inaccesible, pérdida de datos, impacto en todos los usuarios
- **P2 — Alto**: funcionalidad crítica degradada, workaround posible, impacto en muchos usuarios
- **P3 — Medio**: funcionalidad no crítica afectada, workaround simple, impacto acotado

## Flujo abreviado

### 1. Intake

Recopilar la información inicial del incidente:
- Qué está fallando (síntoma observable)
- Impacto en usuarios: cantidad afectada, funcionalidades inaccesibles
- Desde cuándo ocurre
- Ticket INC en el issue tracker
- Severidad preliminar (P1/P2/P3)

### 2. Análisis inmediato

Analizá los artefactos disponibles:
- Logs de aplicación y de infraestructura
- Trazas de error (stack traces, request IDs)
- Métricas y alertas disparadas
- Cambios recientes en producción (deploys, config changes)
- Componentes afectados y sus dependencias

Generá una hipótesis de causa raíz con su nivel de confianza antes de proponer cualquier acción.

### 3. Decisión: hotfix o workaround

Evaluar las opciones:
- **Workaround**: acción inmediata para restaurar el servicio sin tocar código (rollback, feature flag, config change, reencolar mensajes)
- **Hotfix**: cambio mínimo de código necesario para corregir la causa raíz

Para P1: preferir workaround si existe. Hotfix solo si no hay otra opción.

### 4. GATE — aprobación del plan

Antes de tocar producción, el tech lead debe aprobar:
- Diagnóstico preliminar
- Acción elegida (workaround o hotfix)
- Riesgo estimado de la acción
- Plan de rollback si la acción empeora la situación

Este gate no se saltea, ni siquiera en P1. Documentar la aprobación (Slack, Teams o comentario en el INC).

### 5. Fix mínimo

- Si workaround: documentar los pasos exactos y ejecutar con acompañamiento
- Si hotfix: crear rama `hot-fix/{slug}` desde producción, cambio mínimo, PR exprés con al menos un reviewer, merge a producción
- Verificar que el servicio se restauró: smoke test, métricas, confirmación del usuario reportante

### 6. Post-mortem (P1 y P2)

A realizar dentro de las 48 horas posteriores a la resolución:
- Timeline del incidente (detección, análisis, acción, resolución)
- Causa raíz confirmada
- Por qué no fue detectado antes (brechas en monitoreo o tests)
- Acciones preventivas con responsables y fechas

## Guardar en

```
docs/incidents/{ticket}/
  INCIDENT.md        ← diagnóstico, decisión, fix aplicado
  POSTMORTEM.md      ← solo para P1/P2, después de la resolución
```

## Rama (si hotfix)

```
hot-fix/{slug-del-incidente}
```

Merge directo a la rama de producción, luego cherry-pick o merge a main.

## Referencias

- Ticket: INC en el issue tracker
- Cambio de emergencia: CHG de emergencia en el issue tracker (requerido por la organización para cambios en producción fuera del ciclo normal) — ver la skill `sooft` (§6.6 el issue tracker)
- Monitoreo: alertas del entorno productivo
