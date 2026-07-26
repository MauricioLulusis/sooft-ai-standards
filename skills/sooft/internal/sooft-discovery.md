# Recurso interno de `sooft`: discovery

> Recurso interno de la constitución `sooft` — **no es una skill invocable** ni un slash command. Los routers lo cargan leyendo este archivo (`sooft/internal/sooft-discovery.md`) cuando el flujo lo pide. Regí siempre por la skill `sooft` (principios, gates de aprobación, máquina de estados y reglas no negociables).

## Propósito

Ante cualquier pedido de trabajo sobre el código —y **antes de leerlo, analizarlo o tocarlo**, no solo antes de escribir código o documentación—: entender el request, clarificar dudas, identificar los sistemas afectados. El discovery va PRIMERO, siempre.

Este skill es el punto de entrada obligatorio de todo workflow SOOFT. Sin discovery completado no se puede abrir un PRD. Aplica igual en el CLI de Copilot y en la GUI de VS Code.

## Delegación a subagente Copilot CLI

Si estás en **Copilot CLI** y existe el custom agent `sooft-discovery`, usalo siempre que sea posible para la exploración read-only del contexto, identificación de sistemas afectados, supuestos y propuesta de preguntas ante pedidos de investigar, explorar, analizar, revisar, encontrar o diagnosticar código/contexto.

Invocación esperada en Copilot CLI: `@sooft-discovery` en sesión interactiva, o un comando equivalente a `copilot --agent sooft-discovery -p "<pedido de discovery read-only>"` si estás automatizando una corrida no interactiva.

El orquestador principal conserva la responsabilidad de presentar las preguntas al developer, registrar `.sooft/discovery-checklist.json`, actualizar `.sooft/state.json` y decidir el siguiente gate.

Si el subagente no está disponible o Copilot CLI no lo puede lanzar, ejecutá este recurso directamente y registrá ese fallback con motivo en la respuesta/evidencia.

## Cuándo usarlo

El disparador NO es "antes de generar código o un artefacto" — es **ante cualquier pedido de trabajo sobre el código, antes de analizarlo o tocarlo**. Esto cierra el gap más común: "analizar" no produce un artefacto, así que es fácil saltearlo; no lo saltees. El discovery va antes de la primera lectura, búsqueda o apertura de archivo.

- Ante **cualquier** pedido de trabajo sobre el código: bug, feature, cambio funcional, refactor o hotfix.
- **Incluso cuando el developer lo plantea como "analizá", "encontrá", "revisá", "arreglá" o "mirá este archivo".** Que el pedido no pida "generar" un artefacto NO te exime: el discovery va antes de abrir un solo archivo. Nunca te zambullas en el código sin haberlo hecho.
- Cuando llega un ticket del issue tracker (INC, RITM, CHG, REQ) sin contexto adicional.
- Cuando el orchestrator activa el scope-agent por primera vez en un trabajo.

**Única excepción:** consultas puras de información que no van a derivar en un cambio ("explicame qué hace esto", "qué es X", "cómo funciona Y"). Esas no disparan discovery. Si la consulta deriva en un cambio, hacés el discovery antes de tocar nada.

## Pasos

### 1. Leer el proyecto

Antes de hacer preguntas: leer los archivos relevantes del proyecto para entender el stack, la arquitectura y el contexto existente. No preguntar lo que ya se puede saber leyendo el código.

> **Detectar el arquetipo y las librerías es parte del discovery — el catálogo solo acompaña.**
> Lo más importante es lo que descubrís en el proyecto, no lo que asumís del catálogo. Al leer
> el código, derivá de la **evidencia real** qué stack y qué dependencias ya usa:
> - `package.json` → framework (Express/Fastify/NestJS), versión de Node en `engines`, y las
>   dependencias clave (ORM, cliente HTTP, testing).
> - `pom.xml` / `build.gradle` → versión de Java y Spring Boot, plugins de build.
> - `*.csproj` → `<TargetFramework>` (ej. `net8.0`) y los `<PackageReference>` principales; un
>   `netcoreapp3.1` o similar dispara el contexto de migración (`on_demand: migration`).
> - `pyproject.toml` / `requirements.txt` → versión de Python, FastAPI y librerías clave.
> - Versión del runtime → si está vigente o es un stack heredado a migrar.

#### 1.a. Resolver el arquetipo y cargar SOLO su contexto (carga acotada — clave para no sobrecargar)

Con la evidencia del punto anterior, resolvé **un único arquetipo** y cargá **solo su contexto**. La regla de oro es **no traer contexto de stacks que el proyecto no usa**: si es un proyecto Node, NO se leen las referencias de Java (`backend-service/java/**`) ni de .NET (`backend-service/dotnet/**`), y viceversa. Cargar el árbol entero de arquetipos sobrecarga el contexto al pedo y degrada la calidad.

Procedimiento determinista:

1. **Elegí el índice según el stack detectado** y leelo: proyecto **Node** → `skills/sooft/assets/archetypes/node.manifest.yml`; proyecto **Java** → `skills/sooft/assets/archetypes/java.manifest.yml`; proyecto **.NET** → `skills/sooft/assets/archetypes/dotnet.manifest.yml`; proyecto **Python** → `skills/sooft/assets/archetypes/python.manifest.yml`. Es la tabla de ruteo evidencia → contexto del stack. Cargá **un solo** manifest — el del lenguaje primario del proyecto, nunca más de uno.
2. **Resolvé el arquetipo**: recorré los ids en el orden de `detection_order` y quedate con el **primero** cuyo bloque `detect` matchee la evidencia. En Node un `package_scopes` presente alcanza (`node_engines` es señal de apoyo); en Java un `maven_parents` presente alcanza (`java_version` es señal de apoyo); en .NET un `nuget_packages` presente en algún `.csproj` alcanza (`target_framework` es señal de apoyo). El orden codifica precedencia: lo más específico primero (lite antes que original, v2 antes que v1).
3. **Cargá únicamente las referencias de `load`** de ese arquetipo — ese es el contexto base del stack, y nada más. Son rutas relativas a `skills/sooft/assets/archetypes/`.
4. **`on_demand` es perezoso**: cargá una entrada de `on_demand` **solo** si la tarea concreta toca esa preocupación (ej. `http_client` cuando se trabaja un cliente HTTP; `migration` si la evidencia muestra Node < 20; `tests`/`swagger` al generar tests o documentar la API). Si la tarea no la toca, NO la cargues.
5. **Persistí lo resuelto** en `.sooft/state.json`: el `id` del arquetipo en el campo `archetype` y las rutas efectivamente cargadas en `context_loaded`. En los turnos siguientes, **leé `archetype` del state y cargá ese mismo bundle directo, sin volver a inspeccionar el proyecto** (resolver una sola vez). Solo re-resolvé si `archetype` está vacío o si la evidencia cambió (ej. el developer migró de conjunto de librerías).

> **Si ningún `detect` matchea** (proyecto sin arquetipo de Sooft, o stack no cubierto aún en el manifest): no fuerces una carga. Seguí con el discovery normal leyendo el proyecto y marcá `archetype: null` en el state. NUNCA cargues un bundle de otro stack "por las dudas".

#### 1.b. Cruzar contra el catálogo (narrativa humana)

Recién con el arquetipo resuelto, cruzá contra el inventario canónico
(`skills/sooft/assets/archetypes/README.md`) para saber qué más ofrece ese conjunto de librerías, qué **no**
cubre y a dónde ir por el detalle. **Cuando el developer pregunte "qué arquetipos tenemos",
"qué librerías hay para X" o "con qué arranco", respondé combinando lo que detectaste en el
proyecto con el catálogo**: qué ya usa, qué tiene disponible y sin usar, qué no existe. Sobre
esa base se decide qué se reutiliza y qué se construye — nunca se reimplementa lo que el
conjunto de librerías ya provee.

### 2. Leer el ticket del issue tracker (si hay uno)

Si el campo `ticket` en `.sooft/state.json` tiene un valor (ej: `TICKET-12345`, `INC-00456`): extraer de él:
- Descripción del requerimiento o incidente
- Solicitante y equipo responsable
- Fecha límite o urgencia
- Sistemas mencionados
- Criterios de aceptación si los hay

Si no hay ticket: el developer describe la tarea en lenguaje natural.

### 3. Clarificar dudas (hasta 5 preguntas, decididas según el contexto, con opciones para elegir)

**Vos decidís qué preguntar.** No hay una lista fija de preguntas. Según el contexto del ticket/requerimiento y lo que fuiste descubriendo al leer el proyecto (pasos 1 y 2), formulá las preguntas concretas que hacen falta para desambiguar *este* requerimiento puntual. Si algo ya está claro en el ticket o se infiere del código, no lo preguntes.

Guía de temas típicos a cubrir (es un checklist mental de qué suele importar, **no** una lista de preguntas literales obligatorias — usalo como referencia y formulá las preguntas reales según el requerimiento):
- el comportamiento esperado del cambio
- los usuarios o sistemas afectados
- restricciones técnicas o regulatorias
- urgencia o fecha límite
- documentación o contexto previo

**No hagas preguntas de texto abierto.** Cada pregunta se presenta con `AskUserQuestion`, dándole al developer 3 o 4 opciones concretas para elegir en vez de obligarlo a redactar. El developer elige una opción (salvo que elija "Otra").

Reglas del formato:
- Por cada pregunta, generá 3 o 4 opciones inferidas del contexto del ticket/proyecto (inferencias razonables según lo que leíste en los pasos 1 y 2) MÁS una opción final fija: **"Otra (escribí tu respuesta)"**.
- Tanto la pregunta como las primeras opciones las generás vos según el requerimiento. Tienen que ser inferencias plausibles, no genéricas.
- Si el developer elige "Otra (escribí tu respuesta)", recogé su respuesta libre.

Ejemplo concreto de **formato** — para un ticket "crear una pantalla home", el agente decidió preguntar por el tipo de pantalla (tanto la pregunta como las opciones las generó el agente según el contexto) y lo presenta así con `AskUserQuestion`:

```
¿Qué tipo de pantalla home querés?
  1. Pantalla de bienvenida post-login (dashboard simple)
  2. Landing page con navbar y secciones
  3. Panel de administración con menú lateral
  4. Otra (escribí tu respuesta)
```

Límite estricto: **hasta 5 preguntas** en una sola ronda. Es un techo, no un piso: pueden ser 2, 3 o las que hagan falta — no es obligatorio llegar a 5. No conviertas el discovery en un interrogatorio ni hagas rondas sucesivas antes de avanzar.

`.sooft/discovery-checklist.json` es un **registro** de las preguntas que efectivamente hiciste y la opción elegida en cada una (no es un script de preguntas predefinidas): anotá ahí lo que preguntaste y lo que respondió el developer. El esquema canónico del archivo es la plantilla `skills/sooft/assets/templates/discovery-checklist.json`. Marcá con `[NEEDS CLARIFICATION]` todo lo que el developer no pueda resolver (incluso si eligió "Otra" sin dar una respuesta clara). No avances sin las respuestas.

### 4. Identificar sistemas afectados

Listar explícitamente:
- Módulos o servicios del proyecto que se modifican
- APIs, contratos o esquemas de datos que cambian
- Dependencias externas involucradas (otros microservicios, colas, base de datos, el issue tracker)
- Equipos de otras áreas que deben ser notificados o consultados

### 5. Detectar supuestos

Nombrar en voz propia lo que se está asumiendo pero no está escrito. Un supuesto no declarado es un riesgo de scope.

## Exit criteria

El agente puede responder estas cuatro preguntas antes de cerrar el discovery:

- ¿Qué hay que construir o cambiar?
- ¿Quién lo pidió y con qué objetivo de negocio?
- ¿Qué sistemas, módulos o contratos afecta?
- ¿Qué estoy asumiendo que no está escrito?

Si alguna de estas preguntas no tiene respuesta, el discovery no está completo.

## Output

Un resumen estructurado del requerimiento con el siguiente formato:

```
## Resumen de discovery — {slug}

### Qué hay que hacer
[Descripción en 2-4 oraciones de qué se construye o cambia]

### Quién lo pidió y por qué
[Solicitante, equipo, objetivo de negocio]

### Sistemas afectados
- [Sistema / módulo / contrato]
- ...

### Supuestos
- [Supuesto 1]
- ...

### Dudas abiertas
- [Duda con responsable de responder]
- ...

### Ticket el issue tracker
[TICKET-XXXXX o "Sin ticket"]
```

Este resumen es la entrada al PRD (asset `sooft-development/assets/prd.md`).

## Actualizar state.json

```json
{
  "phase": "REQUIREMENT_LOADED",
  "ticket": "<TICKET-XXXXX o null>",
  "owner": "<developer>",
  "created_at": "<fecha ISO>",
  "last_step": "discovery",
  "next_step": "prd-draft"
}
```

## Qué NO hacer

- No hacer más de 5 preguntas antes de avanzar al resumen.
- No escribir código ni documentación técnica en esta fase.
- No asumir que el scope está cerrado si hay dudas abiertas — documentarlas.
- No avanzar al PRD sin haber identificado los sistemas afectados.
- No saltear este skill aunque el request parezca trivial.
- No zambullirte en el código —leer, analizar, buscar, abrir archivos— antes de completar el discovery. Que el pedido diga "analizá", "encontrá", "revisá", "arreglá" o "mirá este archivo" NO es excusa: el discovery va primero, siempre. La única salida es una consulta de información pura que no derive en cambio.
