# Recurso interno de `sooft`: auto-setup de hooks (bootstrap)

> Recurso interno de la constitución `sooft` — **no es una skill invocable** ni un slash command. La constitución lo carga leyendo este archivo (`sooft/internal/sooft-bootstrap.md`) en la primera activación de la skill en la sesión (típicamente al correr `/sooft`, ver §0.0). Regí siempre por la skill `sooft` (principios, gates de aprobación, máquina de estados y reglas no negociables).

## Propósito

Instalar **una sola vez** el hook de sesión, los custom agents de Copilot CLI y los archivos que la GUI de VS Code necesita (instrucciones globales + prompt files). SOOFT funciona también sin esto — la misma regla ya vive en las instrucciones always-on — pero el disparo determinista y gratuito en tokens (banner + trigger de carga de la skill) lo da el **hook de sesión**, cuyo contenido canónico y agnóstico a la herramienta está en `assets/hooks/session-start.yml` (ver §Hook de sesión abajo). Además, la ejecución especializada en Copilot CLI necesita los **custom agents** en `.github/agents/`; y la GUI de VS Code necesita además las **instrucciones globales** (`.github/copilot-instructions.md`) y los **prompt files** que habilitan los slash commands (`/sooft`, `/sooft-development`, `/sooft-bugs`, `/sooft-security-remediation`, `/sooft-status`, `/sooft-incident-response`). `npx skills add` baja la skill con sus assets, pero **no deja por sí solo** hooks, agents ni esos archivos en su lugar funcional. Por eso, **la primera vez que cargás la skill `sooft`** este auto-setup los instala una vez. Ejecutá este procedimiento EN ORDEN.

## Hook de sesión — un solo algoritmo, igual para cualquier herramienta

El contenido (banner + mensaje de contexto) tiene una única fuente de verdad:
**`assets/hooks/session-start.yml`**. Ahí está el `algoritmo_universal`: el mismo
procedimiento de 4 pasos que aplica sin excepción sea cual sea la herramienta donde
estés corriendo esta sesión — Copilot, Claude Code, Cursor, o una que todavía no
existe. Copilot y Claude Code **no son casos especiales**: son, simplemente, las dos
veces que ya se corrió ese algoritmo y el resultado quedó guardado como adapter
reutilizable. El PASO C.1 abajo es ese algoritmo aplicado; C.2 y C.3 son setup
adicional de Copilot que no tiene que ver con el hook (instrucciones, prompts, custom
agents) y no aplica a otras herramientas.

## Procedimiento

```
PASO A — Idempotencia. Si ya existe `~/.copilot/hooks/sooft.json` con "version": 1 (o el
         adapter de tu herramienta actual ya está instalado con el mismo contenido),
         considerá el hook de sesión ya instalado y NO lo reescribas. Igual verificá
         los PASOS C.2 (instrucciones + prompts, solo Copilot) y C.3 (custom agents,
         solo Copilot CLI) por si faltan en ESTE proyecto.

PASO B — Instalá SIEMPRE, sin preguntar. NO pidas confirmación (es parte del setup
         obligatorio de SOOFT, no una opción). En el PASO D lo informás en una línea.

PASO C — Copiá los archivos que vienen en la carpeta `assets/` de ESTA skill.
         Si NO encontrás los assets en la carpeta de la skill, NO inventes el
         contenido: avisá al developer que faltan los assets y **HALT** — no sigas
         con el resto del bootstrap ni con el algoritmo de §0 hasta resolverlo.

         C.1 (hook de sesión — algoritmo universal, CUALQUIER herramienta, una vez por
             máquina/proyecto según corresponda): seguí `assets/hooks/session-start.yml`
             → `algoritmo_universal` al pie de la letra:

             1. ¿Tu herramienta actual ya tiene un adapter resuelto?
                - Copilot (CLI o GUI de VS Code) → `assets/sooft.json`. Necesita DOS
                  ubicaciones porque el CLI y la GUI leen hooks desde lugares distintos:
                    assets/sooft.json   -> ~/.copilot/hooks/sooft.json  (user-level, toda la máquina)
                    assets/banner.txt   -> ~/.copilot/hooks/banner.txt
                    assets/sooft.json   -> .github/hooks/sooft.json     (repo-level, versionado)
                  (El `sessionStart` hace `cat` de `~/.copilot/hooks/banner.txt` para el
                   banner a costo cero de tokens; si falta, cae a una línea de texto.)
                - Claude Code → `assets/hooks/adapters/claude.json`. Una sola ubicación:
                  si `.claude/settings.json` NO existe, creálo con ese contenido completo;
                  si YA existe, MERGEÁ el array `hooks.SessionStart` del adapter dentro
                  del array `hooks.SessionStart` ya presente (concatenar, nunca
                  reemplazar) — si el archivo tiene otras claves (`PreToolUse`, etc.) o
                  cualquier otra configuración del equipo, NO LAS TOQUES. Si ya hay un
                  hook de `SessionStart` con el mismo `command`, no lo dupliques.
                - Cualquier otra herramienta → revisá si existe
                  `assets/hooks/adapters/<tu-herramienta>.json` y aplicá el mismo
                  criterio de merge/no-pisado que corresponda a su formato.
             2. Si NO existe adapter para tu herramienta: ¿tiene un mecanismo de hooks
                nativo (evento de inicio de sesión o equivalente) que puedas CONFIRMAR
                con certeza en este momento, contra su propia documentación real? Si sí,
                traducí `session-start.yml` (`banner_fallback` + `additional_context`)
                a ese formato e instalalo.
             3. Si NO podés confirmarlo: NO instales nada. PROHIBIDO inventar el nombre
                de un evento o la forma de un payload sin esa confirmación. Avisá en el
                PASO D que el hook nativo no se instaló para esta herramienta y seguí
                sin bloquear — SOOFT funciona igual sin él (la misma regla ya está en
                las instrucciones always-on).
             4. Si en el paso 2 construiste y verificaste un adapter nuevo, guardalo en
                `assets/hooks/adapters/<tu-herramienta>.json` antes de seguir — la
                librería crece con el uso real, así el próximo developer con esa misma
                herramienta ya la encuentra resuelta en el paso 1.

         REGLA DE NO PISAR EN TODOS LOS CASOS: si el archivo destino YA existe con
         contenido propio del equipo, mergeá o dejalo — nunca lo sobreescribas entero.

         C.2 (instrucciones + prompts de Copilot, una vez por proyecto): para que la
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

         C.3 (custom agents de Copilot CLI, una vez por proyecto): para que el CLI
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

> Las **instrucciones** (`.github/copilot-instructions.md`) y los **prompt files** que deja el PASO C.2 son **stubs que delegan en las skills** ("cargá `sooft` y seguila"): existen para que la GUI de VS Code tenga las custom instructions always-on y los slash commands `/sooft`, `/sooft-development`, etc., **sin duplicar la metodología**. En el **CLI** los slash commands custom no existen, pero el CLI lee `.github/copilot-instructions.md` igual y carga custom agents desde `.github/agents/`, que deja el PASO C.3. La fuente de verdad es siempre la skill `sooft` y las que cita por nombre.
