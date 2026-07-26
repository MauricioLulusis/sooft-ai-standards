# Cómo contribuir a sooft-ai-standards

Este repositorio define cómo trabaja la IA en el desarrollo de Sooft Technology. Cambiarlo afecta a todos los equipos que lo usan, así que el proceso de contribución es deliberado y revisado.

---

## Antes de proponer un cambio

1. Leé [`AGENTS.md`](AGENTS.md) y la skill [`sooft`](skills/sooft/SKILL.md) para entender la metodología y los 9 principios fundacionales.
2. Verificá que tu cambio respeta esos principios. Un cambio que debilita un gate o un control de seguridad va a ser rechazado.
3. Si el cambio es grande o afecta el comportamiento del agente, abrí primero un issue para discutirlo.

---

## Proceso

1. **Branch** desde la rama target configurada, con nombre tipo Git:
   ```
   feat/{slug}     → nueva skill, regla o capacidad
   fix/{slug}      → corrección
   chore/{slug}    → mantenimiento, docs, refactor
   ```
2. **Hacé el cambio** siguiendo las convenciones de abajo.
3. **Corré o delegá los evals** (ver más abajo) — deben pasar el umbral de la rúbrica.
4. **Actualizá** lo que corresponda: `CHANGELOG.md`, `README.md`, `AGENTS.md` si cambia el conjunto de skills o reglas.
5. **Abrí un MR/PR** hacia la rama target. Asigná revisores según [`CODEOWNERS`](.github/CODEOWNERS).

---

## Convenciones

### Skills (`SKILL.md`)

- Frontmatter obligatorio: `name` (kebab-case), `description` (una línea, en términos de lo que dice el developer), `version`.
- Gates explícitos: cada gate crítico termina con su frase canónica seguida de `**Stop. No avances hasta que el developer diga OK.**`.
- Setup de worktree antes de crear archivos, salvo skills de solo lectura (`status`) o configuración (`init`).
- Sección "Qué NO hacer" al final.

### Lineamientos y reglas (política canónica)

- Las reglas no negociables de seguridad y testing viven en `skills/sooft/assets/policies/` (fuente de verdad), con su resumen always-on en la constitución `sooft` (§6). Editá ahí; no copies las reglas a otros archivos.
- Concretas y accionables, no aspiracionales. Lo no negociable (seguridad) se marca como tal.

### Hooks de agente (`sooft.json`)

- El disparo determinista son **hooks de agente de Copilot** (`sessionStart`), no git hooks `.sh`. Viven en `skills/sooft/assets/`.
- `sooft.json`: el `sessionStart` muestra el banner e inyecta el recordatorio de cargar `sooft`. Sin lógica propia; banner en `banner.txt`.
- Probá en un repo limpio, con y sin `.sooft/`, antes de commitear.

### Idioma

- Skills, reglas, templates y docs en español rioplatense (vos/usá).

---

## Validación

Antes de abrir el MR:

- [ ] Los evals de `evals/v0.1.0/0.2.0/` pasan el umbral de la rubrica (task >= 0.8, suite >= 0.85, ningun hard failure con score > 0). No hay runner propio: pedile a un subagente o harness externo que consuma las tasks.
- [ ] Si el cambio modifica comportamiento del agente, se actualizaron las tasks afectadas y `evals/v0.1.0/0.2.0/migration.md` si corresponde.
- [ ] No se introdujeron secretos, credenciales ni PII.
- [ ] El `CHANGELOG.md` refleja el cambio.
- [ ] Los README afectados quedaron alineados con el cambio.

---

## Qué NO hacer

- No debilitar ni saltear gates de aprobación.
- No hardcodear proveedores externos como obligatorios (la metodología es tool-agnostic).
- No modificar las frases canónicas de gate sin revisar el impacto en todas las skills.
- No mergear sin que los evals vigentes pasen y sin aprobación de un CODEOWNER.

---

Dudas: equipo de AI Platform de Sooft Technology.
