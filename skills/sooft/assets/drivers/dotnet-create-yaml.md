---
description: Genera el contrato OpenAPI 3.0 basándose en api-spec.md y el estándar de Response corporativo (arquetipo .NET de Sooft).
---

# Contexto de Entrada

1. **Reglas de Negocio**: `#file:docs/api-spec.md`
2. **Contrato Actual**: `#file:api-docs/my-app-spec.yaml`

# Rol

Actuá como Arquitecto de APIs experto en OpenAPI 3.0.3. Tu objetivo es actualizar el YAML garantizando que todas las respuestas sigan el estándar de "Envelope Response" de Sooft (`meta-data-error`) provisto por `el paquete base del arquetipo` / `el paquete base del arquetipo`.

# Estándar Obligatorio de Respuesta (Envelope)

Todas las respuestas exitosas y de error deben usar una estructura envolvente con estos tres componentes en `components/schemas`:

1. **Meta**: contiene campos `method` (String) y `operation` (String).
2. **PomError**: objeto detallado para errores. Campos: `reason`, `login-tracking-id`, `code`, `data`, `code_backend`, `code_internal`, `description`, `message`, `title`, `custom_message`, `extensions`, `trace` (Object), `error_type`, `custom_title`, `context`, `detail`, `custom_description`, `lang`, `custom_error_type`, `custom_code`.
3. **ResponseWrapper**: el objeto raíz que debe contener:
   - `meta`: referencia a `Meta`.
   - `errors`: lista de `PomError`.
   - `data`: lista (Array) del objeto de negocio específico (ej: `SynchronizeStatusDataDTO`).

Los tres nombres provistos por el arquetipo de Sooft (`Meta` / `PomError` / `ResponseWrapper`) se mantienen consistentes con el resto del ecosistema de Sooft (Java-Spring, Node-Nest, .NET), aunque los códigos generados en .NET desde este YAML terminen como records/clases `System.Text.Json`.

# Directrices de Diseño

- **Naming**: los objetos de datos dentro de `data` deben llevar el sufijo `DataDTO` (ej: `SynchronizeStatusDataDTO`). El objeto raíz de respuesta debe llamarse `Response[Nombre]DTO`.
- **Estructura**: asegurate de que `data` siempre sea un array, incluso si devuelve un solo elemento.
- **Ejemplos**: incluí valores de ejemplo realistas para cada campo de `PomError` y `Meta` para que Swagger sea funcional.
- **Compatibilidad con codegen .NET**: mantené `snake_case` en JSON solo donde el envelope corporativo lo exija (`login-tracking-id`, `code_backend`, etc.); los DTOs de dominio propios usan `camelCase` por default (el generador NSwag / openapi-generator los mapea a `PascalCase` en C# automáticamente). No mezclar convenciones dentro del mismo schema.
- **Tipos numéricos**: definir explícitamente `format` (`int32` / `int64` / `float` / `double`) para evitar sorpresas del codegen .NET (`decimal` requiere `format: decimal` como extensión — evitar salvo caso confirmado).
- **Nullability**: usar `nullable: true` explícito en OpenAPI 3.0.3 cuando el campo pueda venir null; en C# 8+ los generadores lo mapean a `Nullable<T>` / `string?`.

# Consumo desde el proyecto .NET

- El YAML vive en `api-docs/<nombre-api>.yaml` de la solución.
- Los DTOs se generan con **NSwag** o **openapi-generator-cli** hacia `Generated/` (elegir el generador que ya use el proyecto).
- Los DTOs generados **no se editan a mano**.
- El envelope (`Meta`, `PomError`, `ResponseWrapper`) genera clases/records que conviven con las clases de `ResponseGenerator` del arquetipo: en runtime el arquetipo compone el envelope, este YAML sirve para que el Swagger/documentación externa lo muestre.

# Tarea

Actualizá `my-app-spec.yaml`. Si el archivo está vacío, generá la estructura base de OpenAPI. Si contiene endpoints, asegurate de que sus `responses` apunten a los esquemas de `ResponseWrapper` definidos.
