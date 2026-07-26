# Recurso interno de `sooft`: maintenance

> Recurso interno de la constitución `sooft` — **no es una skill invocable** ni un slash command. El agente lo carga leyendo este archivo (`sooft/internal/sooft-maintenance.md`) cuando el flujo lo pide. Regí siempre por la skill `sooft` (principios, gates de aprobación, máquina de estados y reglas no negociables).

## Cuándo usarlo

Para tareas planificadas que mantienen la salud del sistema sin urgencia operativa:
- Actualización de dependencias (librerías, frameworks, runtime)
- Limpieza de deuda técnica identificada
- Ajustes de configuración o parametrización
- Refactors planificados sin cambio de comportamiento externo
- Archivado o limpieza de datos según políticas de retención

## Diferencia con incident-response

No hay urgencia. El sistema funciona correctamente. El trabajo surge de una decisión proactiva del equipo, no de un incidente activo.

## Flujo

El flujo es el mismo que el de desarrollo, pero con menor urgencia y mayor foco en el riesgo de regresión.

### 1. PRD simplificado

No requiere el PRD completo, pero sí documentar:
- Motivación: por qué se hace este mantenimiento ahora
- Alcance: qué se cambia y qué queda explícitamente fuera del alcance
- Criterio de éxito: cómo saber que el mantenimiento fue exitoso

### 2. Análisis de riesgo

Antes de planificar, evaluar:
- ¿Qué funcionalidad existente puede romperse con este cambio?
- ¿Hay dependencias internas o externas que puedan verse afectadas?
- ¿Existen tests de regresión que cubran las áreas tocadas?
- ¿Se requiere coordinación con otros equipos?

### 3. PLAN

Igual que en desarrollo:
- Pasos de implementación ordenados
- Tests de regresión a ejecutar
- Estrategia de validación antes de mersooft

GATE: el PLAN debe estar aprobado antes de empezar a tocar código.

### 4. Implementación

- Rama: `maintenance/{slug}` o `chore/{slug}`
- Cambios atómicos y descriptivos
- Sin mezclar mantenimiento con nuevas funcionalidades en el mismo PR

### 5. Validación

- Ejecutar el plan de tests de regresión definido
- Verificar que el comportamiento externo no cambió
- Quality gate del análisis estático sin regresión

### 6. Deploy

Seguir el flujo normal de despliegue (el recurso `internal/sooft-release.md` de `sooft`). El mantenimiento no justifica saltarse el proceso de deploy.

## Documentar siempre

- **Motivación**: por qué era necesario este mantenimiento
- **Riesgo**: qué podría romperse y cómo se mitigó
- **Tests de regresión**: qué se ejecutó para validar que nada se rompió
- **Resultado**: estado final, métricas antes/después si aplica (ej: tiempo de build, cobertura de tests, vulnerabilidades cerradas)

## Guardar en

```
docs/maintenance/{ticket}/MAINTENANCE.md
```

## Rama

```
maintenance/{slug}
chore/{slug}
```

## Referencias

- Ticket: RITM o REQ en el issue tracker (para mantenimientos planificados) — ver la skill `sooft` (§6.6 el issue tracker)
- Deuda técnica: puede originarse en hallazgos del análisis estático o revisiones de arquitectura
