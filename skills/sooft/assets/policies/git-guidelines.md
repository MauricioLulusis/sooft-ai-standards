# Lineamientos de Git — Sooft Technology

---

## Principio base

**Historial con intención:** cada commit, rama y PR deja un rastro claro, consistente y mantenible. No se genera ruido; cada entrada del historial tiene propósito.

---

## Conventional Commits

### Formato

```
<tipo>(scope opcional): descripción
```

### Tipos reconocidos (Conventional Commits)

| Tipo       | Uso                                      |
| ---------- | ---------------------------------------- |
| `feat`     | Feature nueva                            |
| `fix`      | Corrección de bug                        |
| `docs`     | Documentación                            |
| `style`    | Cambios de formato sin impacto en lógica |
| `refactor` | Reestructuración sin cambio de comportamiento |
| `test`     | Agregar o corregir tests                 |
| `build`    | Sistema de build o dependencias externas |
| `ci`       | Configuración de CI/CD                   |
| `perf`     | Mejora de rendimiento                    |
| `chore`    | Tareas de mantenimiento generales        |
| `revert`   | Revertir un commit anterior              |

### Reglas

- OBLIGATORIO usar el formato `<tipo>(scope): descripción` en todos los commits.
- OBLIGATORIO commits atómicos: un cambio incremental por commit, encapsulado, incluyendo sus tests y documentación asociada.
- OBLIGATORIO commits funcionales e incrementales: cada commit debe dejar el codebase en un estado válido y consistente.
- OBLIGATORIO que el mensaje del commit describa el razonamiento, contexto, trade-offs, supuestos asumidos y decisiones detrás del cambio, no solo "qué" se hizo.
- OBLIGATORIO proponer un mensaje corregido ante cualquier commit no convencional (ej: "arreglo login" → `fix(auth): corregir validación de sesión`).
- PROHIBIDO commitear con mensajes vagos (`cambio`, `fix2`, `ahora si`, `corrijo review`, `ultimo cambio`).

### Ejemplos correctos

Cada commit incluye asunto, contexto y decisiones tomadas:

```
feat(orders): agregar validación de formato de identificador de pedido

Se valida que el identificador cumpla con el formato definido por la
regla de negocio antes de persistir el pedido. Se descartó validación
client-side porque el servidor es la única fuente de verdad para el
formato vigente. Incluye test unitario y actualización del contrato de
error en docs/api.
```

```
fix(auth): corregir expiración prematura de token JWT

El token expiraba usando la hora UTC del servidor en vez de la hora de
emisión del cliente. Se corrige tomando `iat` como base. Trade-off: no se
migran sesiones activas; los usuarios con sesión abierta deben re-autenticarse.
```

```
refactor(payments): extraer lógica de cálculo de comisiones a servicio propio

La lógica estaba duplicada en tres controllers. Se consolida en
`CommissionService` para facilitar el mantenimiento y el testeo aislado.
Sin cambio de comportamiento observable; los tests de integración existentes
siguen en verde.
```

---

## Estrategia de Branching SOOFT

SOOFT es **worktree-first** (skill `sooft`, principio §1): cada trabajo vive aislado en su
propio worktree y su propia rama, nunca se desarrolla sobre la rama compartida.

### Ramas

| Rama | Propósito |
|---|---|
| `main` (o la rama principal que use el proyecto) | Código estable. PROHIBIDO desarrollar directamente sobre esta rama. |
| `feat/<slug>`, `fix/<slug>`, `security/<slug>`, `migration/<slug>` | Ramas de trabajo, una por `type` de `.sooft/state.json` (`feat`, `bug`→`fix/`, `security`, `migration`). Viven en un worktree propio: `.worktrees/<tipo>-<slug>`. |

### Convención de nombres

`<slug>` es una descripción corta en kebab-case, sin ticket embebido — la trazabilidad al
ticket vive en `.sooft/state.json.ticket` (ej. `TICKET-XXXXX`), no en el nombre de la rama.

Correcto: `feat/orders-search-filter`, `fix/token-expiration`, `security/xss-header`, `migration/node-20-upgrade`

PROHIBIDO: `feature1`, `cambio`, `prueba`, `fix123`

### Flujo de integración

```
main (rama compartida)
  ↓ git worktree add .worktrees/<tipo>-<slug> -b <tipo>/<slug>
<tipo>/<slug>  (aislado en su worktree)
  ↓ Pull Request, solo tras confirmación explícita del developer (skill sooft §4, regla 7)
main
```

Si el proyecto usa un modelo de branching distinto (rama de integración propia, `release/<version>`,
etc.), seguí ESE modelo — PROHIBIDO asumir un destino fijo sin evidencia de cómo integra el proyecto
(mismo criterio que "no asumas el issue tracker sin evidencia").

### Pasos obligatorios

1. Crear el worktree y la rama desde la rama principal actualizada: `git worktree add .worktrees/<tipo>-<slug> -b <tipo>/<slug>` (ver skill `sooft` y el router correspondiente para el comando exacto por tipo).
2. Crear commits.
3. Abrir Pull Request solo tras la confirmación explícita del developer, contra la rama principal del proyecto salvo que haya evidencia de que el proyecto usa otro destino.

---

## Pull Requests

### Validaciones obligatorias

- OBLIGATORIO documentar el objetivo del PR.
- OBLIGATORIO asociar el ticket correspondiente.
- OBLIGATORIO que los tests estén ejecutados y en verde.
- OBLIGATORIO identificar el impacto (cambios incompatibles, riesgo, dependencias afectadas).
- OBLIGATORIO verificar el destino del PR contra el modelo de branching real del proyecto (por defecto, la rama principal — PROHIBIDO asumir `release/<version>` u otro destino sin evidencia).
- OBLIGATORIO que el PR permita revertir los cambios de forma segura.
- ADVERTIR si el PR supera 400 líneas y recomendar división en PRs más pequeños.
- ADVERTIR: Un unico cambio conceptual y autocontenido por PR.

### Checklist de calidad (antes del merge)

```
✅ Objetivo documentado
✅ Ticket asociado
✅ Tests ejecutados
✅ Impacto identificado
⚠️ PR superior a 400 líneas → recomendar dividir
```

### Formato sugerido para la descripción del PR

```markdown
## Objetivo
<qué implementa o corrige este PR>

## Cambios realizados
- <cambio 1>
- <cambio 2>

## Impacto
<cambios incompatibles / sin cambios incompatibles>

## Evidencia
<capturas, resultados de pruebas, logs>
```
---

## Manejo del Historial Git

### `git commit --amend`

**Cuándo usarlo:** corregir el mensaje del último commit, agregar archivos olvidados, pequeños ajustes. OBLIGATORIO hacerlo **antes del push**. PROHIBIDO aplicarlo sobre commits ya publicados en remoto.

### `git rebase -i HEAD~N`

**Cuándo usarlo:** limpiar historial antes de abrir el PR, consolidar commits relacionados, eliminar ruido, reordenar commits.

Operaciones disponibles: `pick` · `edit` · `squash` · `drop` · `reorder`

**Ejemplo:**

Antes: `fix` / `fix2` / `ahora si` / `corrijo review` / `ultimo cambio`

Después: `feat(transfers): implementar validación de alias`

OBLIGATORIO recomendar `git rebase -i` cuando la rama tenga commits desordenados o ruidosos antes del merge.

---

## Estrategias de Merge

### Opciones disponibles

| Estrategia | Comportamiento | Usar cuando |
|---|---|---|
| **Merge Commit** | Conserva toda la historia, genera commit de merge | Se necesita máxima trazabilidad; existen múltiples commits relevantes |
| **Squash Merge** | Consolida todos los commits en uno | La rama tiene commits intermedios/ruido; la funcionalidad es autocontenida y se busca historial limpio |
| **Rebase and Merge** | Mantiene commits individuales, genera historial lineal | Los commits tienen valor histórico y la rama fue mantenida prolijamente |

### Motor de recomendación

| Escenario | Recomendación | Motivo |
|---|---|---|
| Feature compleja con commits claramente organizados (RECOMENDADO) | Rebase and Merge | Mantiene trazabilidad sin introducir commits de merge |
| Feature pequeña con varios commits que pueden conformar un solo commit atomico autocontenido | Squash Merge | Reduce ruido histórico y deja una única entrada representando la funcionalidad |
| Cambio que requiere máxima trazabilidad de cada paso (NO RECOMENDADO) | Merge Commit | Conserva toda la historia del desarrollo |

---

## Criterios de aceptación

| ID | Dado | La Skill debe |
|---|---|---|
| CA-01 | Un commit no convencional | Proponer versión compatible con Conventional Commits |
| CA-02 | Un escenario de branching | Recomendar Trunk-Based o Gitflow justificando la decisión |
| CA-03 | Un Pull Request | Generar checklist de calidad antes del merge |
| CA-04 | Un escenario de Code Review | Generar observaciones alineadas con el orden recomendado |
| CA-05 | Un problema de historial Git | Explicar el uso de amend y rebase interactivo |
| CA-06 | Un PR listo para integrarse | Recomendar Merge, Rebase o Squash según el contexto |
| CA-07 | Una rama nueva a crear | Sugerir nombre descriptivo alineado al tipo de trabajo |
| CA-08 | Un PR desde rama de trabajo | Validar el destino contra el modelo de branching real del proyecto (por defecto, la rama principal), nunca asumir `release/<version>` sin evidencia |
| CA-09 | Un conjunto de commits desordenados | Sugerir limpieza mediante rebase interactivo |
