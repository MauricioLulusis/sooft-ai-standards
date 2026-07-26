# Technical Spec

> Parte de `sooft-development`. No invocar directamente.

## Propósito

Producir una especificación técnica completa antes de planificar la implementación. Convierte el PRD aprobado en un documento de diseño concreto que el equipo puede revisar y aprobar.

## Prerrequisito

El PRD debe estar aprobado (phase >= PRD_APPROVED) antes de activar este paso.

## Delegación a subagente Copilot CLI

Si estás en **Copilot CLI** y existe el custom agent `sooft-spec-architect`, delegá la elaboración de la SPEC técnica a ese subagente para aprovechar contexto aislado y modelo fuerte. El orquestador SOOFT conserva el gate de SPEC, la actualización de estado y la decisión de si la SPEC aplica. El subagente no aprueba SPEC ni implementa código.

Si el subagente no está disponible, seguí este recurso directamente.

## Cuándo ES requerido

Crear SPEC.md cuando el cambio cumple al menos una de estas condiciones:

- Toca múltiples sistemas o servicios
- Cambia el modelo de datos (nuevas tablas, columnas, relaciones, migraciones)
- Implica permisos, autenticación o autorización
- Requiere integraciones externas (APIs de terceros, el issue tracker, sistemas legados)
- Incluye migración de datos en producción
- Presenta riesgo arquitectural (acoplamiento, performance, disponibilidad)
- El developer lo solicita explícitamente

## Cuándo NO es requerido

Para cambios locales y acotados la SPEC puede omitirse. En ese caso documentar en el PLAN.md la razón explícita de por qué se omitió. Ejemplos válidos de omisión:

- Cambio de texto o configuración sin impacto estructural
- Bug fix acotado a un único componente sin cambio de contrato
- Refactor interno sin cambio de API ni modelo de datos

## Dónde guardar

```
docs/feats/{slug}/SPEC.md
```

## Estructura del documento

La estructura canónica de la SPEC es la plantilla `skills/sooft/assets/templates/SPEC.md`. **Leéla y seguíla** como molde — no la reproduzcas acá. Cubre arquitectura y diseño, modelo de datos, API y contratos, seguridad y permisos, integraciones externas, rollout y migración, alternativas consideradas, riesgos y estrategia de tests, con la regla `[NEEDS CLARIFICATION]` y la coherencia rastreable al PRD.

## GATE

Una vez redactada la SPEC, detener y mostrar este mensaje:

> SPEC técnica lista en `docs/feats/{slug}/SPEC.md`. Revisala antes de que continúe.

No avanzar al plan de implementación hasta recibir aprobación explícita del developer.
