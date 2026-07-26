# Capa de compatibilidad con GitHub Copilot

sooft-ai-standards está escrito para Claude Code (`AGENTS.md` + `skills/sooft/`), pero el mismo comportamiento está disponible para **GitHub Copilot** (CLI y VS Code) a través de esta carpeta `.github/`.

Esto resuelve un problema concreto: **la GUI de VS Code Copilot no lee `AGENTS.md`** y, sin configuración, no lanza el discovery. Esta capa lo arregla **de forma automática**: el setup de VS Code ya no requiere que el developer toque nada a mano.

---

## Qué hay acá

| Archivo | Qué hace | Quién lo lee |
|---------|----------|--------------|
| `copilot-instructions.md` | Reglas globales (discovery, gates, principios, seguridad) | Copilot CLI **y** VS Code (Ask/Edit/Agent) |
| `agents/*.agent.md` | Custom agents de Copilot CLI para primitivas SOOFT especializadas (discovery, PRD, SPEC, PLAN, testing, reviews, evidence, release) | Copilot CLI |
| `agents/MODELS.md` | Política de modelos, fallbacks y validación local para subagentes | Humans + Copilot CLI |
| `prompts/sooft.prompt.md` | Inicializa SOOFT en el proyecto: banner + **auto-setup de los hooks de agente de Copilot** (`.github/hooks/sooft.json` + `~/.copilot/hooks/`) + detección de stack/integraciones + `.sooft/` (equivale a `/sooft` en Claude Code) | **VS Code** (`/sooft`). En CLI: "inicializá SOOFT" |
| `prompts/sooft-development.prompt.md` | Flujo de feature completo | `/sooft-development` |
| `prompts/sooft-bugs.prompt.md` | Flujo de bug | `/sooft-bugs` |
| `prompts/sooft-security-remediation.prompt.md` | Flujo de remediación | `/sooft-security-remediation` |
| `.vscode/settings.json` | Activa `useInstructionFiles`, `chat.promptFiles` y `chat.mcp.autoStart` (arranca el MCP del issue tracker solo) al abrir el proyecto | VS Code (lo lee solo al abrir la carpeta) |

---

## Setup en VS Code (AUTOMÁTICO — no tocás nada)

**Ya no hay paso manual.** El proyecto trae un `.vscode/settings.json` que activa la config sola apenas abrís la carpeta en VS Code:

```json
{
  "github.copilot.chat.codeGeneration.useInstructionFiles": true,
  "chat.promptFiles": true,
  "chat.mcp.autoStart": true
}
```

- `useInstructionFiles: true` → hace que VS Code aplique `copilot-instructions.md`.
- `promptFiles: true` → habilita los prompt files invocables con `/`.
- `chat.mcp.autoStart: true` (Experimental) → VS Code levanta el MCP del issue tracker solo al detectar `.vscode/mcp.json` (queda solo la confianza del server, por única vez).

### Cómo queda puesto

El init de `/sooft` deja ese `.vscode/settings.json` en el proyecto del developer (junto con los hooks de agente). A partir de ahí, cuando el developer abre el proyecto en VS Code, la GUI lee las instrucciones **sin que configure absolutamente nada a mano**: no hay que editar el `settings.json` del usuario ni tocar la Settings UI.

> **Cómo llegan `copilot-instructions.md`, los prompt files y los custom agents al proyecto destino.** No quedan en su ubicación funcional solo con `npx skills add` (que baja las skills y sus assets). Los instala el **auto-setup de `/sooft`** (§0.1 de la skill `sooft`), copiándolos desde `skills/sooft/assets/` al `.github/` del destino: `copilot-instructions.md`, `prompts/*.prompt.md` y `agents/*`. Las instrucciones y prompts son **stubs que delegan en la skill `sooft`**; los agents son perfiles de Copilot CLI para primitivas especializadas. Si un archivo ya existe en el destino, no se pisa (puede estar personalizado).

> El **CLI de Copilot** tampoco necesita config a mano: ya toma `copilot-instructions.md` automáticamente, y el MCP del issue tracker lo levanta el **`.mcp.json`** (clave `mcpServers`) que `/sooft` deja en la raíz —el CLI no lee `.vscode/mcp.json`, pero sí `.mcp.json`—. Así que ahora **CLI y GUI quedan parejos** sin intervención del developer.

---

## Cómo verificar que cargó

Truco del *sentinel*: preguntale a Copilot Chat:

> "¿Qué dice la Regla #1 de tus instrucciones?"

Si responde con la regla del discovery (que es obligatorio antes de tocar código), está en contexto. Si no, revisá:

1. Que el archivo esté en `.github/copilot-instructions.md` (ubicación exacta).
2. Que exista `.vscode/settings.json` en la raíz del proyecto con `useInstructionFiles`, `chat.promptFiles` y `chat.mcp.autoStart` en `true` (lo deja `/sooft`; si no está, correlo de nuevo).
3. Que `useInstructionFiles` esté en `true` (puede estar pisado por el `settings.json` del usuario).
4. Que abriste VS Code en la **carpeta del proyecto** (el `.vscode/settings.json` solo aplica si la carpeta abierta es la raíz, no un padre).
5. Que reiniciaste/recargaste la ventana de VS Code tras la primera apertura.

---

## Cómo lo usa el developer

```
En VS Code Copilot Chat (modo Agent), con / (prompt files):

  /sooft                   → inicializa SOOFT en el proyecto (una vez)
  /sooft-development            → feature completa con gates
  /sooft-bugs                   → corrección de bug
  /sooft-security-remediation   → remediación
  /sooft-status                 → estado actual del pipeline
  /sooft-incident-response      → incidente en producción (hotfix)

O describe el trabajo en lenguaje natural: copilot-instructions.md ya le
dice que tiene que hacer el discovery antes de empezar.
```

> **En el CLI de Copilot NO existen estos `/comandos`.** Los slash commands custom desde `.github/prompts/` son una feature de la **GUI de VS Code** (gated por `chat.promptFiles`); el CLI solo tiene sus comandos built-in y devuelve `Unknown command: /sooft`. Es una [limitación abierta de GitHub](https://github.com/github/copilot-cli/issues/618). En el CLI, pedí lo mismo en **lenguaje natural** ("inicializá SOOFT", "arrancá un feature…"): el CLI sí lee `copilot-instructions.md` automáticamente, que ya tiene los pasos de inicialización y las reglas.
>
> **`/init` tampoco sirve como atajo en el CLI.** No es un comando built-in de Copilot CLI ([referencia de comandos](https://docs.github.com/en/copilot/reference/copilot-cli-reference/cli-command-reference)) y, al ser custom, choca con la misma limitación que `/sooft`: el CLI lo rechaza antes de que el modelo lo vea. Por eso el banner en el CLI se dispara **solo por lenguaje natural** ("inicializá SOOFT", "init"). En el init, el agente **imprime el banner como texto** (contenido de `skills/sooft/assets/banner.txt`, la fuente de verdad del arte/texto), como **bloque preformateado**. Se eligió texto porque así se ve **completo e inline** en CLI e IDE, sin que el developer tenga que expandir nada. La contra: el texto toma el **color del tema** de la CLI, no naranja.

> **¿Y el banner en naranja?** El arte/texto vive en `skills/sooft/assets/banner.txt` (la fuente de verdad). En el init el agente lo imprime como **bloque preformateado**: se ve **completo e inline** en CLI e IDE, sin que el developer tenga que expandir nada. La contra es que toma el color del tema de la terminal, no naranja.

---

## Custom agents y subagentes en Copilot CLI

Copilot CLI puede cargar custom agents desde `.github/agents/`. En SOOFT se usan solo para **primitivas especializadas**, no para reemplazar los skills principales ni sus gates. Esos agents viajan como assets de la skill (`skills/sooft/assets/agents/`) y `/sooft` los materializa en `.github/agents/` del proyecto destino.

- Los skills principales (`sooft`, `sooft-development`, `sooft-bugs`, `sooft-security-remediation`, `sooft-status`, `sooft-incident-response`) siguen siendo la fuente de verdad del workflow.
- Los custom agents hacen trabajo acotado en contexto separado: discovery, PRD, SPEC, PLAN, bug analysis, test strategy, security review, code review, evidence y release notes.
- La política de modelos vive en `.github/agents/MODELS.md`.
- Para routing determinista por agente, no arranques la sesión principal con `model: auto`; usá un modelo explícito y dejá que cada agente use su `model` o el override configurado.

Comandos útiles en Copilot CLI:

```copilot
/model       # ver modelos disponibles para tu usuario/org
/subagents   # configurar modelos por subagente
/agent       # listar o invocar custom agents
```

También podés invocar uno explícitamente:

```sh
copilot --agent sooft-security-reviewer --prompt "Review the current diff for security issues"
```

Si un modelo fue removido o bloqueado por policy, aplicá el fallback de `.github/agents/MODELS.md` y registrá la decisión en `.sooft/evidence.md`.

### Validación local de subagentes

Para validar la estructura de los custom agents y el cableado básico en las skills:

```sh
sh ci/validate-copilot-agents.sh
```

El validador no llama a Copilot ni consume créditos. Verifica:

- existen los 10 perfiles `.github/agents/*.agent.md` esperados;
- cada perfil tiene `name`, `description`, `model`, `tools` y referencia a `MODELS.md`;
- los modelos usados tienen fila de fallback en `.github/agents/MODELS.md`;
- `sooft-security-reviewer` y `sooft-code-reviewer` son read-only;
- `.github/copilot-instructions.md` y `skills/sooft/assets/copilot-instructions.md` mencionan todos los subagentes;
- las instrucciones priorizan usar `sooft-discovery` y los demás subagentes siempre que estén disponibles, antes de resolver con el agente principal;
- las instrucciones conservan la regla de no delegar gates.

---

## Cobertura del discovery

El discovery es **obligatorio en CLI y en GUI por igual**: ningún entorno está exento. Lo garantiza la instrucción global más el trigger de carga de la skill:

| Mecanismo | Cuándo actúa | Tipo |
|-----------|-------------|------|
| `copilot-instructions.md` (Regla #1) | Al **inicio** — el agente lanza las preguntas (CLI y GUI) | Blando (instrucción) |
| Hook `sessionStart` (`.github/hooks/sooft.json` + `~/.copilot/hooks/`) | En **cada sesión nueva** — muestra el banner e inyecta el recordatorio de cargar `sooft` (CLI y GUI) | Trigger determinista |

El `sessionStart` hace determinista el **disparo** (el banner y el recordatorio aparecen siempre), y la Regla #1 de `copilot-instructions.md` hace que el agente lance el discovery antes de tocar código. Los dos los instala `/sooft` en `.github/hooks/` + `~/.copilot/hooks/`, leídos por CLI y GUI, así que corren igual en ambas superficies.

---

## Mantenimiento

Si cambian las reglas en `AGENTS.md` o en las skills (`skills/`), actualizá también `copilot-instructions.md` y los prompt files para mantener la paridad entre Claude Code y Copilot. Es la misma metodología expresada en dos formatos.

> Los **stubs** que se distribuyen al proyecto destino viven en `skills/sooft/assets/copilot-instructions.md` y `skills/sooft/assets/prompts/`. Como **delegan en las skills** (no copian las reglas), casi nunca hay que tocarlos: solo si cambia la *forma de delegar* (nombre de una skill, la lista de flujos), no cuando cambia una regla de comportamiento.
