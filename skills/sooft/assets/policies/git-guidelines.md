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
feat(payments): agregar validación de formato de identificador de beneficiario

Se valida que el identificador cumpla con el formato definido por la
regla de negocio antes de persistir el pago. Se descartó validación
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

### Ramas

| Rama | Propósito |
|---|---|
| `master` / `main` | Código estable listo para producción. PROHIBIDO desarrollar directamente sobre esta rama. |
| `release/<version>` | Consolida cambios antes de integrarlos a la rama principal (ej: `release/0.1.0`, `release/1.0.0`). |
| `feat/<descripción>`, `fix/<descripción>`, `docs/<descripción>`, `chore/<descripción>` | Ramas de trabajo. Se crean desde la rama principal con nombres descriptivos. |

### Convención de nombres para feature branches

Correcto: `feat/cvu-validation`, `fix/token-expiration`, `docs/api-guide`

PROHIBIDO: `feature1`, `cambio`, `prueba`, `fix123`

### Flujo de integración

```
master / main
  ↓ (crear branch)
feat/* / fix/* / docs/* / chore/*
  ↓ (Pull Request)
rama de integración del equipo (develop, release/<version>, master, etc.)
```

### Pasos obligatorios

1. Crear branch desde la rama principal del proyecto (`master` o `main`) actualizada: `git checkout <rama-principal> && git pull && git checkout -b feat/<descripción>`.
2. Crear commits.
3. Abrir Pull Request contra la rama de integración que use el equipo. PROHIBIDO asumir un destino fijo sin conocer el modelo de branching del proyecto.

---

## Pull Requests

### Validaciones obligatorias

- OBLIGATORIO documentar el objetivo del PR.
- OBLIGATORIO asociar el ticket correspondiente.
- OBLIGATORIO que los tests estén ejecutados y en verde.
- OBLIGATORIO identificar el impacto (cambios incompatibles, riesgo, dependencias afectadas).
- OBLIGATORIO verificar que el destino del PR sea `release/<version>` y no la rama principal (`master` / `main`).
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
| CA-08 | Un PR desde rama de trabajo | Validar que el destino sea `release/<version>`, no la rama principal (`master` / `main`) |
| CA-09 | Un conjunto de commits desordenados | Sugerir limpieza mediante rebase interactivo |
