---
description: Genera el contrato OpenAPI 3.0 basándose en api-spec.md y un estándar de envelope de respuesta uniforme.
---

# Contexto de Entrada

1. **Reglas de Negocio**: `#file:docs/api-spec.md`
2. **Contrato Actual**: `#file:api-docs/my-app-spec.yaml`

# Rol

Actuá como Arquitecto de APIs experto en OpenAPI 3.0.3. Tu objetivo es actualizar el YAML garantizando que todas las respuestas sigan un envelope uniforme (`meta`/`data`/`errors`).

# Estándar de Respuesta (Envelope)

Todas las respuestas exitosas y de error deben usar una estructura envolvente con estos tres componentes en `components/schemas` (ejemplo ilustrativo — ajustá los campos al contrato real del proyecto):

1. **Meta**: contiene campos `method` (String) y `operation` (String).
2. **ApiError**: objeto de error. Campos mínimos sugeridos: `code`, `message`, `details`, `traceId`. Agregá los que el dominio necesite.
3. **ResponseWrapper**: el objeto raíz que debe contener:
   - `meta`: referencia a `Meta`.
   - `errors`: lista de `ApiError`.
   - `data`: lista (Array) del objeto de negocio específico (ej: `SynchronizeStatusDataDTO`).

# Directrices de Diseño

- **Naming**: los objetos de datos dentro de `data` deben llevar el sufijo `DataDTO` (ej: `SynchronizeStatusDataDTO`). El objeto raíz de respuesta debe llamarse `Response[Nombre]DTO`.
- **Estructura**: asegurate de que `data` siempre sea un array, incluso si devuelve un solo elemento.
- **Ejemplos**: incluí valores de ejemplo realistas para cada campo de `ApiError` y `Meta` para que Swagger sea funcional.
- **Convención de casing**: usá `camelCase` por default en el JSON de los DTOs de dominio (el generador NSwag / openapi-generator los mapea a `PascalCase` en C# automáticamente). No mezclar convenciones dentro del mismo schema.
- **Tipos numéricos**: definir explícitamente `format` (`int32` / `int64` / `float` / `double`) para evitar sorpresas del codegen .NET (`decimal` requiere `format: decimal` como extensión — evitar salvo caso confirmado).
- **Nullability**: usar `nullable: true` explícito en OpenAPI 3.0.3 cuando el campo pueda venir null; en C# 8+ los generadores lo mapean a `Nullable<T>` / `string?`.

# Consumo desde el proyecto .NET

- El YAML vive en `api-docs/<nombre-api>.yaml` de la solución.
- Los DTOs se generan con **NSwag** o **openapi-generator-cli** hacia `Generated/` (elegir el generador que ya use el proyecto).
- Los DTOs generados **no se editan a mano**.
- El envelope (`Meta`, `ApiError`, `ResponseWrapper`) se implementa en el proyecto (middleware/filtro de respuesta); este YAML sirve para que el Swagger/documentación externa lo muestre.

# Tarea

Actualizá `my-app-spec.yaml`. Si el archivo está vacío, generá la estructura base de OpenAPI. Si contiene endpoints, asegurate de que sus `responses` apunten a los esquemas de `ResponseWrapper` definidos.
