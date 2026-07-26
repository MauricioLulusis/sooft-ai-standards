---
name: sooft-checkpoint
description: Ejecuta una compaction manual del snapshot de estado del proyecto (STATUS.md + snapshot rotativo) sin cambiar la fase del workflow. Útil para cerrar el día en medio de IMPLEMENTING o para forzar un snapshot antes de una pausa larga.
---

# Checkpoint

> Esta skill es parte de SOOFT. Antes de usarla, seguí la skill `sooft` (principios, gates de aprobación, máquina de estados y reglas no negociables). Este skill **NO cambia la fase** del workflow, solo dispara un snapshot manual.

## Qué hace

1. Lee `.sooft/state.json`. Si no existe o `phase == IDLE`: informa que no hay workflow activo y sugiere `/sooft`.
2. Actualiza in-place el `STATUS.md` versionado (`docs/{tipo}/{slug}/STATUS.md`) reflejando el estado actual del trabajo.
3. Escribe un snapshot efímero en `.sooft/status/YYYY-MM-DDTHH-MM.md` (formato Windows-friendly).
4. Aplica retención FIFO: si hay más de 10 snapshots en `.sooft/status/`, elimina el más viejo. (Los snapshots de gates aprobados en `.sooft/status/gates/` no rotan).
5. Registra una línea en `.sooft/evidence.md`: `<YYYY-MM-DD HH:MM> — checkpoint manual — <razón opcional>`.
6. Reporta al developer una línea de confirmación con la ruta del snapshot y el conteo de snapshots retenidos.

## Cuándo usarlo

- Antes de una pausa larga (fin del día, fin de semana, cambio de contexto).
- Al llegar a un hito informal dentro de una fase (ej: mitad de las tareas del PLAN completadas, pero sin transición todavía).
- Después de una decisión de arquitectura significativa que quedó registrada en `evidence.md` pero aún no se reflejó en `STATUS.md`.
- Antes de compartir el trabajo con un colega para que arranque otra sesión sobre la misma rama.

## Pasos

### Paso 1 — Verificar workflow activo

Leé `.sooft/state.json`. Si no existe, o si `phase == IDLE`, respondé:

```
No hay workflow activo. /sooft-checkpoint requiere un workflow en curso.
```

Y detené acá.

### Paso 2 — Determinar rutas

Del `state.json` extraé `type` y `slug`. Ruta del STATUS.md versionado:

- `feat` → `docs/feats/{slug}/STATUS.md`
- `bug` → `docs/bugs/{slug}/STATUS.md`
- `security` → `docs/security/{slug}/STATUS.md`

Ruta del snapshot efímero: `.sooft/status/YYYY-MM-DDTHH-MM.md` (usar fecha/hora local, formato Windows-friendly sin `:`).

### Paso 3 — Actualizar STATUS.md versionado

- Si NO existe, generarlo desde el template `skills/sooft/assets/status-template.md` con las 7 secciones obligatorias.
- Si existe, actualizar in-place: refrescar Metadatos (última actualización), agregar decisiones nuevas de `evidence.md` desde el último update, actualizar la checklist de progreso desde `PLAN.md`, archivar riesgos cerrados.
- Verificar RF-05 (anti-drift): `STATUS.md.phase == state.json.phase` OBLIGATORIO. Si diverge, HALT y reportar.
- Verificar RNF-02: cap 200 líneas. Si excede, compactar (no truncar).

### Paso 4 — Escribir snapshot rotativo

- Crear la carpeta `.sooft/status/` si no existe.
- Copiar el `STATUS.md` recién actualizado a `.sooft/status/YYYY-MM-DDTHH-MM.md`.
- Aplicar retención: listar snapshots en `.sooft/status/` (excluir `gates/`), ordenar por nombre (equivale a orden cronológico), eliminar los que excedan de 10 desde el más viejo.

### Paso 5 — Registrar en evidence.md

Agregar una línea al final de `.sooft/evidence.md`:

```
## <YYYY-MM-DD HH:MM> · Checkpoint manual

- Snapshot escrito en `.sooft/status/YYYY-MM-DDTHH-MM.md`.
- STATUS.md versionado actualizado.
- Razón: <razón provista por el developer o "no especificada">.
```

### Paso 6 — Confirmar al developer

Respondé una línea:

```
Checkpoint registrado. STATUS.md actualizado + snapshot en .sooft/status/<file>. Snapshots retenidos: N/10.
```

## Qué NO hacer

- **NO cambiar `phase` en `state.json`**. Este skill es idempotente respecto a la máquina de estados.
- **NO transicionar el workflow**. Si el developer quiere transicionar, usa el flujo normal del driver correspondiente.
- **NO escribir contenido prohibido** (RF-08 de `status-template.md`): sin PII, secretos, transcripts crudos, stack traces.
- **NO tocar** `.sooft/status/gates/` (los snapshots permanentes de gates aprobados).
- **NO forzar el reset** del contador FIFO. La retención es transparente al developer.

## Transición

Este skill **NO cambia `phase`**. Solo actualiza `last_step` de `state.json` a `checkpoint` (y `next_step` se mantiene igual al anterior).

## Ver también

- `skills/sooft/assets/status-template.md` — contrato del artefacto STATUS.md
- `skills/sooft/internal/sooft-implement-task.md` — compaction automática en cada transición
- `skills/sooft-status/SKILL.md` — lectura read-only del estado
- `skills/sooft/internal/sooft-evidence.md` — contrato de evidence.md
