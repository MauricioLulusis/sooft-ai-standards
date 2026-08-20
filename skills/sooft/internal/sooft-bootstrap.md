# Recurso interno de `sooft`: auto-setup de hooks (bootstrap)

> Recurso interno de la constitución `sooft` — **no es una skill invocable** ni un slash command. La constitución lo carga leyendo este archivo (`sooft/internal/sooft-bootstrap.md`) en la primera activación de la skill en la sesión (típicamente al correr `/sooft`, ver §0.0). Regí siempre por la skill `sooft` (principios, gates de aprobación, máquina de estados y reglas no negociables).

## Propósito

Instalar **una sola vez** el hook de sesión, los custom agents de Copilot CLI y los archivos que la GUI de VS Code necesita (instrucciones globales + prompt files). SOOFT funciona también sin esto — la misma regla ya vive en las instrucciones always-on — pero el disparo determinista y gratuito en tokens (banner + trigger de carga de la skill) lo da el **hook de sesión**, cuyo contenido canónico y agnóstico a la herramienta está en `assets/hooks/session-start.yml` (ver §Hook de sesión abajo). Además, la ejecución especializada en Copilot CLI necesita los **custom agents** en `.github/agents/`; y la GUI de VS Code necesita además las **instrucciones globales** (`.github/copilot-instructions.md`) y los **prompt files** que habilitan los slash commands (`/sooft`, `/sooft-development`, `/sooft-bugs`, `/sooft-security-remediation`, `/sooft-status`, `/sooft-incident-response`). `npx skills add` baja la skill con sus assets, pero **no deja por sí solo** hooks, agents ni esos archivos en su lugar funcional. Por eso, **la primera vez que cargás la skill `sooft`** este auto-setup los instala una vez. Ejecutá este procedimiento EN ORDEN.

## Hook de sesión — agnóstico a la herramienta

El contenido (banner + mensaje de contexto) tiene una única fuente de verdad:
**`assets/hooks/session-start.yml`**. Cada herramienta con mecanismo de hooks nativo lo
traduce a su propio formato; ninguna traducción inventa contenido nuevo, todas repiten
el mismo `banner_fallback` y `additional_context` de ese spec. Antes de instalar nada,
identificá con qué herramienta estás corriendo esta sesión:

- **GitHub Copilot (CLI o GUI de VS Code):** adapter ya implementado, ejecutá PASOS
  C.1–C.4 abajo.
- **Claude Code:** adapter ya implementado en `assets/hooks/claude-settings-fragment.json`,
  ejecutá el PASO C.5 abajo.
- **Cualquier otra herramienta:** no hay adapter hardcodeado a propósito — ver PASO C.6.
  PROHIBIDO inventar el nombre de un evento o el formato de un payload que no puedas
  confirmar contra la documentación real de esa herramienta.

> **Dónde se instalan y por qué dos lugares.** Tanto el **CLI** de Copilot como la **GUI de VS Code** leen hooks del mismo formato desde dos ubicaciones: el directorio de usuario `~/.copilot/hooks/` y el del repo `.github/hooks/`. Para que el banner y el trigger funcionen **sin depender de ningún setting** y en ambas superficies, SOOFT escribe el hook en las dos:
> - `~/.copilot/hooks/sooft.json` → user-level (lo lee el CLI siempre; la GUI también).
> - `.github/hooks/sooft.json` → repo-level (lo lee la GUI por defecto y el CLI; queda versionado, así el hook viaja con el repo para todo el equipo).

## Procedimiento

```
PASO A — Idempotencia. Si ya existe `~/.copilot/hooks/sooft.json` con "version": 1,
         considerá el user-level ya instalado y NO lo reescribas. Igual verificá
         los PASOS C.2 (hook repo-level), C.3 (instrucciones + prompts) y C.4
         (custom agents) por si faltan en ESTE proyecto.

PASO B — Instalá SIEMPRE, sin preguntar. NO pidas confirmación (es parte del setup
         obligatorio de SOOFT, no una opción). En el PASO D lo informás en una línea.

PASO C — Copiá los archivos que vienen en la carpeta `assets/` de ESTA skill.
         Si NO encontrás los assets en la carpeta de la skill, NO inventes el
         contenido: avisá al developer que faltan los assets y **HALT** — no sigas
         con el resto del bootstrap ni con el algoritmo de §0 hasta resolverlo.

         C.1 (user-level, una vez por máquina): creá `~/.copilot/hooks/` si no existe y copiá:
               assets/sooft.json       -> ~/.copilot/hooks/sooft.json
               assets/banner.txt      -> ~/.copilot/hooks/banner.txt
         (El `sessionStart` hace `cat` de `~/.copilot/hooks/banner.txt` para mostrar el banner
          a costo cero de tokens; si falta, cae a una línea de texto.)

         C.2 (repo-level, una vez por proyecto): creá `.github/hooks/` en la raíz del
             proyecto si no existe y copiá:
               assets/sooft.json       -> .github/hooks/sooft.json

         C.3 (instrucciones + prompts de Copilot, una vez por proyecto): para que la
             GUI de VS Code tenga las custom instructions always-on y los slash commands,
             y el CLI tenga las instrucciones, copiá (creando `.github/` y
             `.github/prompts/` si faltan; los prompt files viven en `assets/prompts/`):
               assets/copilot-instructions.md                          -> .github/copilot-instructions.md
               assets/prompts/sooft.prompt.md                    -> .github/prompts/sooft.prompt.md
               assets/prompts/sooft-development.prompt.md        -> .github/prompts/sooft-development.prompt.md
               assets/prompts/sooft-bugs.prompt.md               -> .github/prompts/sooft-bugs.prompt.md
               assets/prompts/sooft-security-remediation.prompt.md  -> .github/prompts/sooft-security-remediation.prompt.md
               assets/prompts/sooft-migrations.prompt.md         -> .github/prompts/sooft-migrations.prompt.md
               assets/prompts/sooft-status.prompt.md             -> .github/prompts/sooft-status.prompt.md
               assets/prompts/sooft-incident-response.prompt.md  -> .github/prompts/sooft-incident-response.prompt.md
             REGLA DE NO PISAR: si el archivo destino YA existe, NO lo sobreescribas
             (puede estar personalizado por el equipo) — dejalo y seguí. Estos archivos
             son **punteros** que delegan en las skills; NO duplican la metodología: la
             fuente de verdad sigue siendo la skill `sooft`.

          C.4 (custom agents de Copilot CLI, una vez por proyecto): para que el CLI
             pueda cargar los subagentes SOOFT desde el proyecto destino, creá
             `.github/agents/` si falta y copiá:
               assets/agents/MODELS.md                          -> .github/agents/MODELS.md
               assets/agents/sooft-discovery.agent.md            -> .github/agents/sooft-discovery.agent.md
               assets/agents/sooft-prd-writer.agent.md           -> .github/agents/sooft-prd-writer.agent.md
               assets/agents/sooft-spec-architect.agent.md       -> .github/agents/sooft-spec-architect.agent.md
               assets/agents/sooft-plan-writer.agent.md          -> .github/agents/sooft-plan-writer.agent.md
               assets/agents/sooft-bug-analyst.agent.md          -> .github/agents/sooft-bug-analyst.agent.md
               assets/agents/sooft-test-strategist.agent.md      -> .github/agents/sooft-test-strategist.agent.md
               assets/agents/sooft-security-reviewer.agent.md    -> .github/agents/sooft-security-reviewer.agent.md
               assets/agents/sooft-code-reviewer.agent.md        -> .github/agents/sooft-code-reviewer.agent.md
               assets/agents/sooft-evidence-writer.agent.md      -> .github/agents/sooft-evidence-writer.agent.md
               assets/agents/sooft-release-writer.agent.md       -> .github/agents/sooft-release-writer.agent.md
             REGLA DE NO PISAR: si el archivo destino YA existe, NO lo sobreescribas
             (puede estar personalizado por el equipo) — dejalo y seguí. Los agents
             viajan como assets de la skill `sooft` para que `npx skills add` los
             transporte y `/sooft` los materialice donde Copilot CLI los lee.

         C.5 (Claude Code, SOLO si el harness actual es Claude Code, una vez por
             proyecto): leé `assets/hooks/claude-settings-fragment.json` — es el
             mismo hook de C.1/C.2 traducido al formato de Claude Code. Si
             `.claude/settings.json` NO existe, creálo con ese contenido completo. Si
             YA existe, MERGEALO: agregá el array `hooks.SessionStart` del fragment al
             array `hooks.SessionStart` ya presente (concatenar, no reemplazar) — si
             el archivo tiene otras claves de `hooks` (`PreToolUse`, etc.) o cualquier
             otra configuración, NO LAS TOQUES. REGLA DE NO PISAR: si detectás que ya
             hay un hook de `SessionStart` con el mismo `command` (mismo contenido),
             no lo dupliques.

         C.6 (cualquier otra herramienta, SOLO si tiene su propio mecanismo de hooks
             documentado y no es Copilot ni Claude Code): traducí el contenido de
             `assets/hooks/session-start.yml` (banner_fallback + additional_context)
             al formato nativo de esa herramienta, únicamente si podés confirmar el
             nombre real del evento equivalente a "inicio de sesión" y la forma real
             del payload contra la documentación de esa herramienta en este momento.
             Si no podés confirmarlo con certeza, NO instales nada acá — NO inventes
             el formato. Avisá al developer en el PASO D que el hook de sesión no se
             instaló para esta herramienta (SOOFT sigue funcionando igual, la misma
             regla ya está en las instrucciones always-on) y seguí sin bloquear.

PASO D — Confirmá en UNA línea qué quedó instalado, sin fricción. NO le pidas al
         developer que abra una sesión nueva ni que reinicie nada: SOOFT ya está
         activo en ESTA sesión porque la constitución (la skill `sooft`) está cargada y
         rige el trabajo desde ya (discovery, gates, reglas). Los hooks quedan
         instalados y agregan el enforcement duro/determinista **a partir de la
         próxima sesión, de forma automática** (el harness de la herramienta lee los
         hooks al iniciar la sesión, por eso no aplican a la actual — no es algo que
         el developer deba accionar). Seguí con el algoritmo de §0.
```

> Qué hacen esos hooks, una vez instalados (los corre el harness de la herramienta, NO el agente → no gastan tokens de razonamiento; valen igual en CLI y en GUI):
> - **`sessionStart` / `SessionStart`**: muestra el banner e inyecta el recordatorio de cargar `sooft` en cada sesión nueva. Mismo contenido en todas las herramientas — fuente única en `assets/hooks/session-start.yml`.

> Las **instrucciones** (`.github/copilot-instructions.md`) y los **prompt files** que deja el PASO C.3 son **stubs que delegan en las skills** ("cargá `sooft` y seguila"): existen para que la GUI de VS Code tenga las custom instructions always-on y los slash commands `/sooft`, `/sooft-development`, etc., **sin duplicar la metodología**. En el **CLI** los slash commands custom no existen, pero el CLI lee `.github/copilot-instructions.md` igual y carga custom agents desde `.github/agents/`, que deja el PASO C.4. La fuente de verdad es siempre la skill `sooft` y las que cita por nombre.
