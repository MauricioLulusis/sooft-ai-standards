# Recurso interno de `sooft`: release

> Recurso interno de la constitución `sooft` — **no es una skill invocable** ni un slash command. El agente lo carga leyendo este archivo (`sooft/internal/sooft-release.md`) cuando el flujo lo pide. Regí siempre por la skill `sooft` (principios, gates de aprobación, máquina de estados y reglas no negociables).

## Cuándo usarlo

Cuando el PR está aprobado y todos los tests pasaron, y el equipo necesita preparar la documentación y los artefactos del release antes del deploy a producción.

## Precondición obligatoria

No generar notas de release sin que se cumplan ambas condiciones:
- El PR está aprobado en el repositorio (al menos un approval del tech lead)
- Todos los tests del pipeline pasan (quality gate de calidad incluido)

Si alguna condición no se cumple, detener y notificar al developer.

## Delegación a subagente Copilot CLI

Si estás en **Copilot CLI** y existe el custom agent `sooft-release-writer`, delegá la redacción de notas de release, checklist de deploy, rollback y comunicación a stakeholders a ese subagente. El orquestador SOOFT verifica precondiciones, conserva estado y no permite release sin PR aprobado y tests verdes.

Si el subagente no está disponible, seguí este recurso directamente.

## Qué produce

### 1. Notas de release

Basadas en los PRDs y artefactos del ciclo de vida (alcance, diseño, desarrollo, pruebas):
- Resumen ejecutivo del cambio (una o dos oraciones)
- Lista de funcionalidades nuevas o modificadas
- Bugs corregidos (con referencia a tickets)
- Cambios de comportamiento que los usuarios o sistemas integrados deben conocer
- Deuda técnica resuelta (si aplica)

### 2. Checklist de deploy

Pasos ordenados y verificables antes, durante y después del deploy:
- Prerequisitos: ramas mergeadas, artefactos listos, aprobaciones obtenidas
- Dependencias de infraestructura: servicios externos, colas, bases de datos
- Variables de entorno: nuevas o modificadas, con valores esperados por ambiente
- Migraciones pendientes: scripts de base de datos, orden de ejecución, estimación de tiempo
- Pasos del deploy: secuencia exacta, responsable de cada paso
- Validaciones post-deploy: endpoints a verificar, métricas a observar, smoke tests

### 3. Plan de rollback

Cómo revertir si algo falla durante o después del deploy:
- Trigger: qué condición dispara el rollback (métrica, error rate, alerta)
- Decisor: quién autoriza el rollback
- Pasos de rollback: secuencia exacta, incluyendo reversión de migraciones si aplica
- Tiempo estimado de rollback
- Estado del sistema tras el rollback: qué funcionalidades quedan afectadas

### 4. Comunicación a stakeholders

Mensaje claro y no técnico para los interesados:
- Qué cambió y por qué
- Impacto esperado en el negocio o en los usuarios
- Ventana de deploy: fecha, hora, duración estimada
- Canales de comunicación y responsable del anuncio
- Plan de contingencia resumido (si el deploy falla)

## Flujo de trabajo

1. Verificar precondiciones (PR aprobado + tests verdes)
2. Recopilar artefactos del ciclo: PRD, SPEC, PLAN, PR description
3. Generar los cuatro artefactos del release
4. Revisar con el developer y ajustar
5. Guardar en `docs/releases/{version}/RELEASE.md`
6. Actualizar `.sooft/state.json`: phase → RELEASING

## Guardar en

```
docs/releases/{version}/RELEASE.md
```

Donde `{version}` sigue semver: `v1.2.3` o `v1.2.3-rc1` para release candidates.

## Referencias

- Ticket origen: campo `ticket` en `.sooft/state.json`
- Pipeline: CI/CD del repositorio
- Calidad: quality gate del análisis estático
- Gestión de cambios: CHG en el issue tracker (si aplica para cambios en producción) — ver la skill `sooft` (§6.6 el issue tracker)
