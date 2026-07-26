---
description: Genera/actualiza el contrato OpenAPI code-first con @nestjs/swagger, respetando el Envelope Response corporativo.
---

# Contexto de Entrada

1. **Reglas de Negocio**: `#file:docs/api-spec.md` (si existe)
2. **Bootstrap actual**: `#file:src/main.ts`
3. **Config de Swagger**: `#file:src/config/configuration.ts`

# Rol

Actuá como Arquitecto de APIs experto en **NestJS + @nestjs/swagger** (enfoque **code-first**, NO YAML-first). Tu objetivo es definir/actualizar el contrato OpenAPI **a partir de decoradores sobre DTOs y controllers**, garantizando que todas las respuestas sigan el estándar de "Envelope Response" de Sooft.

> En Node el contrato **no** se escribe a mano en YAML: se genera desde el código con `DocumentBuilder` + decoradores (`@ApiProperty`, `@ApiResponse`, `@ApiTags`, etc.). El YAML es una salida, no la fuente.

# Estándar Obligatorio de Respuesta (Envelope)

Todas las respuestas (éxito y error) viajan en el envelope del arquetipo (`response-parser`), con tres componentes:

1. **meta**: `{ url, method, status }`.
2. **data**: **siempre un array** del objeto de negocio, incluso si devuelve un solo elemento.
3. **errors**: lista de errores con la forma de Sooft (`code`, `message`, `description`, `error_type`, etc.).

# Directrices de Diseño

- **DTOs**: definí los objetos de negocio como clases con decoradores `@ApiProperty({ example: ... })` y validadores de `class-validator`. Sufijo `DataDto` para el objeto dentro de `data` (ej. `OwnerDataDto`).
- **Wrapper**: tipá la respuesta como `Response<TDataDto>` con `meta`, `data: TDataDto[]`, `errors`. Nombrá el wrapper `Response[Nombre]Dto`.
- **Controllers**: anotá cada endpoint con `@ApiTags`, `@ApiOperation`, `@ApiResponse({ status, type: Response[Nombre]Dto })` para 200 y para los errores relevantes (400/403/404/500).
- **DocumentBuilder**: en `main.ts`/módulo de swagger, configurá título, versión, server y seguridad. Usá `completePropertiesAPIM(document)` del arquetipo para agregar las propiedades que exige APIm.
- **Ejemplos**: incluí `example` realista en cada `@ApiProperty` para que el Swagger UI sea funcional.

# Tarea

Generá/actualizá los **DTOs decorados** y las **anotaciones de los controllers** para que el `SwaggerModule.createDocument(...)` produzca un contrato OpenAPI con el envelope corporativo. Si ya existe el setup de Swagger, asegurá que todos los endpoints referencien el `Response[Nombre]Dto`. No escribas el YAML a mano: que salga del código.

# Restricciones

1. No hardcodear `title`/`version`/`server`: tomarlos de `configuration.ts`.
2. No omitir `completePropertiesAPIM(document)`.
3. `data` siempre array.
4. No exponer PII de ejemplo real (usar datos ficticios).
5. Marcá el código generado con `// [IA-generated] SOOFT — revisar antes de mersooft. Ticket: <TICKET-XXXXX>`.
