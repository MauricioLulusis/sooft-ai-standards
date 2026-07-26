---
description: Genera el contrato OpenAPI 3.0 basándose en api-spec.md y el estándar de Response corporativo.
---

# Contexto de Entrada

1. **Reglas de Negocio**: `#file:docs/api-spec.md`
2. **Contrato Actual**: `#file:src/main/resources/api-docs/my-app-spec.yaml`

# Rol

Actuá como Arquitecto de APIs experto en OpenAPI 3.0.3. Tu objetivo es actualizar el YAML garantizando que todas las respuestas sigan el estándar de "Envelope Response" de Sooft.

# Estándar Obligatorio de Respuesta (Envelope)

Todas las respuestas exitosas y de error deben usar una estructura envolvente con estos tres componentes en `components/schemas`:

1. **Meta**: contiene campos `method` (String) y `operation` (String).
2. **PomError**: objeto detallado para errores. Campos: `reason`, `login-tracking-id`, `code`, `data`, `code_backend`, `code_internal`, `description`, `message`, `title`, `custom_message`, `extensions`, `trace` (Object), `error_type`, `custom_title`, `context`, `detail`, `custom_description`, `lang`, `custom_error_type`, `custom_code`.
3. **ResponseWrapper**: el objeto raíz que debe contener:
   - `meta`: referencia a `Meta`.
   - `errors`: lista de `PomError`.
   - `data`: lista (Array) del objeto de negocio específico (ej: `SynchronizeStatusDataDTO`).

# Directrices de Diseño

- **Naming**: los objetos de datos dentro de `data` deben llevar el sufijo `DataDTO` (ej: `SynchronizeStatusDataDTO`). El objeto raíz de respuesta debe llamarse `Response[Nombre]DTO`.
- **Estructura**: asegurate de que `data` siempre sea un array, incluso si devuelve un solo elemento.
- **Ejemplos**: incluí valores de ejemplo realistas para cada campo de `PomError` y `Meta` para que Swagger sea funcional.

# Tarea

Actualizá `my-app-spec.yaml`. Si el archivo está vacío, generá la estructura base de OpenAPI. Si contiene endpoints, asegurate de que sus `responses` apunten a los esquemas de `ResponseWrapper` definidos.
