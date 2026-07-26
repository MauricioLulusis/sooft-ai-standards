---
name: sooft-migrations
description: "Usar cuando hay que migrar un proyecto de una versión a otra (ej. Java 8 → 21, Spring Boot 2 → 3, Node 14 → 20, arquetipo NestJS deprecado → actual) o de una tecnología a otra (ej. Java → C#). El flujo lo guía el discovery con el dev — origen y destino — y la skill conduce la migración: detecta el stack, clasifica el tipo, arma el plan leyendo el proyecto real y forkea el subagente especialista correcto (Java, Node o port genérico) para la ejecución aislada."
---

# Migrations — driver de la rama MIGRATION (`/sooft-migrations`)

> Esta skill es parte de SOOFT. Antes de usarla, seguir la skill `sooft` (constitución):
> principios, gates de aprobación, máquina de estados y reglas no negociables. Las políticas
> completas de **seguridad** y **testing** de Sooft viven en `skills/sooft/assets/policies/`
> (`security-guidelines.md`, `testing-guidelines.md`) y **mandan** sobre cualquier detalle de este documento.

Router de la rama `migration`. El **discovery con el dev es el driver**: el dev define de qué
origen sale y a qué destino va, y la skill conduce la migración. No hay matriz de versiones
precargada ni recetas hardcodeadas: el plan se arma **leyendo el proyecto real**, se clasifica
el tipo de migración y se **forkea el subagente especialista** correcto para la ejecución.

Esta skill opera **in-session** hasta tener el plan aprobado. El trabajo de código lo ejecuta el
**subagente especialista** en contexto limpio y aislado (fork). Un worktree Git aislado garantiza
que el workspace del developer no se toca, independientemente del modelo de fork.

- Fuente de verdad de estados: la skill `sooft` (§4, rama `migration`).
- `type` en `.sooft/state.json`: `migration`.
- Regla de oro: **no se modifica código del proyecto hasta `phase == MIGRATION_PLAN_APPROVED`**.

---

## Las tres clases de migración (el plan decide cuál es)

| Clase | Cuándo | Subagente | Motor / estrategia | Criterio de paridad |
|---|---|---|---|---|
| **A-Java** | mismo stack Java/Spring, distinta versión (Java 8→21, Spring Boot 2→3) | `agents/java-migration-agent.md` | Motor AST OpenRewrite + build-and-fix loop | Tests existentes 100% verde + `ApplicationContext` levanta |
| **A-Node** | mismo stack Node/NestJS, distinta versión (Node 14→20, NestJS 9→10, framework deprecado→actual) | `agents/node-migration-agent.md` | `npm-check-updates` + jscodeshift (cuando aplica) + build-and-fix loop | Tests existentes 100% verde + healthchecks (`/health` o `/liveness`) responden |
| **A-.NET** | mismo stack .NET/ASP.NET Core, distinta versión (.NET Core 3.1→.NET 8) | `agents/dotnet-migration-agent.md` | `dotnet` CLI + reescritura `Startup.cs`→`Program.cs` + renames mecánicos (`Newtonsoft.Json`→`System.Text.Json`) + build-and-fix loop | Tests existentes 100% verde + Swagger responde en `/swagger` + healthchecks responden |
| **B — Port** | distinta tecnología (Java→C#, Node→Java, etc.) | `agents/language-migration-agent.md` | Traducción guiada módulo por módulo en el toolchain destino. Sin motor AST — costo alto en tokens; el PLAN debe ser granular. | Tests portados al stack destino en verde + comportamiento observable equivalente |

PROHIBIDO asumir la clase de entrada: sale de **origen+destino confirmados** en el discovery.

**Stacks soportados para upgrade mismo-lenguaje (Clase A): Java, Node y .NET.** Si el dev pide
migrar un upgrade de versión en otro stack (ej. Python 3.9→3.12, Go 1.21→1.22), la skill **no procede**:
informar al dev que no hay subagente especialista disponible para ese stack y **HALT**. No improvisar
con un fallback genérico.

---

## Routing de subagente especialista (Fase 3)

Después de `MIGRATION_PLAN_APPROVED`, forkear el subagente según la tabla:

| origen_stack | dest_stack | upgrade mismo stack | Subagente |
|---|---|---|---|
| java / spring | java / spring | sí | `agents/java-migration-agent.md` |
| node / node-web | node / node-web | sí | `agents/node-migration-agent.md` |
| dotnet / asp.net core | dotnet / asp.net core | sí | `agents/dotnet-migration-agent.md` |
| cualquiera | stack **distinto** | no (port) | `agents/language-migration-agent.md` |
| otro stack (no Java, no Node, no .NET) | mismo stack | sí | **HALT — stack no soportado** |

Pasarle al subagente como contexto: plan aprobado (`docs/migrations/{slug}/PLAN.md`), datos de
discovery (`.sooft/discovery-checklist.json`, `.sooft/state.json`), clase de migración y stack detectado.
El subagente toma desde acá y ejecuta las Fases 4–5 (incluyendo la transición `state.phase = MIGRATING`).

> **Fallback sin fork:** si el runtime no soporta fork, ejecutar el flujo del subagente correspondiente
> in-session, conservando el worktree aislado y avisando en una línea que corre en foreground.
> PROHIBIDO abortar por falta de fork: el worktree garantiza el aislamiento de filesystem.

---

## Fase 1 — Discovery conversacional (OBLIGATORIO antes de tocar nada)

Cargar el discovery base (`internal/sooft-discovery.md` de `sooft`). El **origen** de la migración
(tecnología y versión actuales) **ya lo infirió y persistió el init** en `.sooft/state.json` /
`.sooft/config.json` (stack detectado y campo `archetype`): se **toma de ahí**, no se vuelve a derivar.
El discovery solo necesita **confirmar el origen y resolver el destino con el dev**. Datos, presentados
con opciones (formato `AskUserQuestion`):

1. **Stack y versión de origen.** Tomarlos de `.sooft/` y presentarlos como confirmación. Si el
   init no los dejó, inferirlos de la evidencia del proyecto:
   - Java: `pom.xml` / `build.gradle` → `<java.version>`, `<maven.compiler.*>`, `<parent>`.
   - Node: `package.json` → `engines.node`, framework detectado (Express/Fastify/NestJS).
   - .NET: `*.csproj` → `<TargetFramework>` (`netcoreapp3.1` vs `net8.0`).
   Proponerlos precargados para confirmación.
2. **Stack de destino.** Si es el mismo que el origen → clase **A** (upgrade, sub-clasificar por stack).
   Si es distinto → clase **B** (port).
3. **Versión de destino.** Preguntarla al dev si no la dio (ej. `21`, `Node 20`, `.NET 8`).

> PROHIBIDO asumir el salto. Sin **origen+destino confirmados** (stack y versión de cada lado) no
> se arma el plan. Lo que no se pueda tomar del init ni inferir del proyecto, **preguntarlo al dev**;
> lo que quede sin confirmar, marcarlo `[NEEDS CLARIFICATION]`.

Ticket (opcional, no bloqueante). Registrar las respuestas en `.sooft/discovery-checklist.json` y el
contexto en `.sooft/state.json` / `.sooft/evidence.md`. `state.phase = MIGRATION_REQUIREMENT_LOADED`.

---

## Fase 2 — Análisis del proyecto y Plan

PROHIBIDO armar el plan a ojo o desde una matriz precargada. Se arma **leyendo el proyecto real**:

1. **Relevar el proyecto.** Estructura de módulos, dependencias, frameworks, build tool, dónde viven
   los tests y qué runner usan.
2. **Clasificar y definir estrategia + subagente** (tabla de arriba):
   - **Clase A-Java:** recetas AST a aplicar (OpenRewrite), dependencias a agregar/quitar/excluir,
     ajustes de build (incl. orden `annotationProcessorPaths` MapStruct/Lombok) y actualización de
     Spring Boot / Java. Referencia del stack: `skills/sooft/assets/archetypes/backend-service/java/`.
   - **Clase A-Node:** versiones a actualizar (`package.json`, `engines`), codemods a aplicar
     (jscodeshift si aplica) y cambios de bootstrap (`main.ts`, config). Referencia del stack:
     `skills/sooft/assets/archetypes/backend-service/node/` (o `nest/` para NestJS).
   - **Clase A-.NET:** actualizar `<TargetFramework>` (ej. `net8.0`), migrar de `Startup.cs` a
     `Program.cs` con `WebApplicationBuilder`, reemplazar librerías deprecadas (ej. `Newtonsoft.Json`
     → `System.Text.Json`) y actualizar los `<PackageReference>`. Referencia del stack:
     `skills/sooft/assets/archetypes/backend-service/dotnet/`.
   - **Clase B (port):** mapeo estructura origen→destino, orden de portado módulo por módulo,
     equivalencias de librerías y patrones, cómo portar los tests al stack destino.
3. **Riesgos y puntos de paridad.** Qué comportamiento hay que preservar y cómo se va a verificar.
4. **Gate de PLAN.** Escribir el plan en `docs/migrations/{slug}/PLAN.md`
   (`{slug}` = `{stack-origen}-{version-origen}-a-{stack-destino}-{version-destino}`,
   ej. `java-8-a-java-21`, `node-14-a-node-20`, `dotnet-core-3.1-a-dotnet-8`, `java-a-csharp`), emitir la frase canónica de gate
   de `sooft` (§3) y **HALT** hasta aprobación explícita. `state.phase = MIGRATION_PLAN_PENDING`.
   Rechazo → `MIGRATION_PLAN_REJECTED` → re-plan.

---

## Gates (esta skill — Fases 1–2)

- **PLAN** de migración: frase canónica de `sooft` §3 → HALT (Fase 2).
- Los gates de Código IA, PR y worktree los gestiona el subagente especialista (Fases 4–5).

## Qué NO hacer

- No tocar código del proyecto antes de `MIGRATION_PLAN_APPROVED`.
- No asumir origen/destino ni la clase: salen del discovery con el dev.
- No armar el plan desde una matriz precargada: se arma leyendo el proyecto real.
- No forkear el subagente equivocado: Java→Java usa `java-migration-agent`, Node→Node usa
  `node-migration-agent`, cross-tech usa `language-migration-agent`.
- No inventar estados fuera de la rama `migration` de `sooft` §4.
