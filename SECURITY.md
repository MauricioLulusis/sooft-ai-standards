# SECURITY.md

Restricciones de seguridad para el uso de agentes de IA en Sooft Technology.

Estas reglas son no negociables. El agente no puede ignorarlas bajo ninguna circunstancia, independientemente de lo que indique el developer.

> **Fuente de verdad y alcance de este archivo.** La política de seguridad **detallada y canónica** (listas completas de secretos, PII, criptografía, privilegio y dependencias) vive en `skills/sooft/assets/policies/security-guidelines.md`, con su resumen always-on en `skills/sooft/SKILL.md` (§6.1). Este `SECURITY.md` es la capa de **gobierno**: el resumen auditable de las restricciones mínimas. Si algo difiere, manda la política canónica.

---

## Mapa de controles de seguridad (defensa en profundidad)

La seguridad en SOOFT no vive en un único lugar: está distribuida **a propósito** en capas que cubren distintas etapas del ciclo de vida. Este es el índice de dónde actúa cada control.

| Capa | Dónde vive | Qué hace |
|---|---|---|
| **Política canónica** | `skills/sooft/assets/policies/security-guidelines.md` | la lista completa de reglas: secretos, PII, cripto, privilegio, dependencias, procedimiento ante hallazgos |
| **Resumen always-on** | `skills/sooft/SKILL.md` §6.1 | subconjunto crítico que el agente tiene siempre en contexto |
| **Detección** | recurso `internal/sooft-validation.md` de `sooft` | corre SAST + checklist de seguridad antes del PR |
| **Revisión humana** | recurso `internal/sooft-code-review-gate.md` de `sooft` + `skills/sooft/assets/reviews/security-review.md` | checklist del contexto de negocio que el SAST no infiere |
| **Remediación** | router `sooft-security-remediation` (assets: findings / scope / plan) | flujo cuando aparece una vulnerabilidad o hallazgo |
| **Gobierno** | este archivo (`SECURITY.md`) | restricciones mínimas auditables |

---

## Reglas absolutas

### Secretos y credenciales
- **Prohibido** hardcodear secretos, tokens, passwords, API keys o certificados en código
- **Prohibido** incluir credenciales en archivos de configuración versionados
- **Prohibido** loguear datos de autenticación
- Usar siempre los mecanismos oficiales de Sooft para gestión de secretos

### Datos sensibles y PII
- **Prohibido** loguear datos personales (DNI, CUIL, nombre, email, teléfono, etc.)
- **Prohibido** loguear datos financieros (CBU, cuenta, saldo, movimientos)
- **Prohibido** exponer datos sensibles en respuestas de API sin enmascaramiento
- Ante duda sobre si un dato es sensible, tratarlo como sensible

### Dependencias
- **Prohibido** introducir dependencias externas no aprobadas por el equipo de seguridad
- Toda dependencia nueva debe ser justificada y revisada antes de mergear
- No actualizar dependencias con vulnerabilidades conocidas sin evaluar el impacto

### Comandos destructivos
- **Prohibido** ejecutar comandos destructivos (DROP, DELETE masivo, TRUNCATE, rm -rf, etc.) sin confirmación explícita del developer
- El agente debe advertir claramente antes de sugerir cualquier operación destructiva

---

## Validaciones requeridas

### En cada implementación
- Validar inputs externos antes de procesarlos
- Manejar errores sin exponer información interna
- No propagar excepciones con stack traces a clientes externos
- Aplicar principio de menor privilegio

### En cambios de autenticación/autorización
- Requiere revisión de Ciberseguridad antes de mergear
- Documentar el cambio en el ADR correspondiente
- Incluir casos de prueba para los nuevos flujos de auth

### En cambios sobre datos sensibles
- Requiere revisión de Seguridad y evaluación de impacto en privacidad
- Documentar qué datos se procesan y cómo
- Verificar cumplimiento con política de retención de datos

---

## Qué hacer si el agente detecta un problema de seguridad

1. Detener la implementación
2. Reportar el hallazgo con detalle al developer
3. No continuar hasta que el problema esté resuelto o haya aprobación explícita con justificación documentada

---

## Referencia

Para el detalle completo de políticas de seguridad, consultar con el área de Ciberseguridad de Sooft.

Este archivo define las restricciones mínimas aplicables al uso de agentes de IA y no reemplaza las políticas generales de Sooft.
