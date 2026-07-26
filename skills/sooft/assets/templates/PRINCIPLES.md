# Principios del Proyecto — <nombre del proyecto>

**Versión:** 1.0
**Última actualización:** <YYYY-MM-DD>
**Mantenido por:** <equipo o tech lead>

> Este documento define las reglas técnicas **propias de este proyecto** que el agente debe respetar en cada feature, bug o cambio. Es el contrato técnico estable: lo que acá se decide, no se vuelve a discutir en cada tarea.
>
> Vive en `.sooft/PRINCIPLES.md` dentro del proyecto. El agente lo lee al inicio de cada sesión y lo respeta como restricción dura — por encima de cualquier preferencia que aparezca en una tarea puntual.
>
> Es la capa de proyecto. Se complementa con: `AGENTS.md` (comportamiento global del agente en Sooft), `GOVERNANCE.md` (controles de Sooft) y las `rules/` del plugin (estándares técnicos transversales).

---

## Stack y Versiones

> Las tecnologías fijas del proyecto. El agente no introduce alternativas sin que se actualice este documento.

| Capa | Tecnología | Versión | Notas |
|------|-----------|---------|-------|
| Lenguaje | <Java / Node.js / …> | <versión> | <fija / mínima> |
| Framework | <Spring Boot / Express / …> | <versión> | |
| Base de datos | <PostgreSQL / Oracle / …> | <versión> | |
| Testing | <JUnit + Mockito / Jest / …> | <versión> | |
| Build | <Maven / Gradle / npm> | <versión> | |

---

## Arquitectura

> Los patrones y límites estructurales que el agente respeta. No se violan sin un ADR aprobado.

- **Patrón:** <hexagonal / capas / MVC / …>
- **Capas y dependencias permitidas:** <ej: controller → service → repository; nunca al revés>
- **Qué NO se hace:** <ej: lógica de negocio en controllers; acceso directo a BD desde controllers>
- **Organización de módulos:** <cómo se estructura el código>

---

## Convenciones de Código

- **Nomenclatura:** <convención de nombres de clases, métodos, paquetes>
- **Manejo de errores:** <excepciones tipadas, sin stack traces al cliente, etc.>
- **Logging:** <formato estructurado, niveles, qué se loguea y qué no>
- **Estilo:** <linter/formatter configurado, ej: Checkstyle, ESLint + Prettier>

---

## Restricciones No Negociables

> Heredadas de `SECURITY.md` de Sooft, reafirmadas a nivel proyecto. El agente las trata como límites absolutos.

- Sin secretos, tokens ni credenciales hardcodeadas — siempre desde el vault o variables de entorno.
- Sin PII en logs: documento, teléfono, número de tarjeta, nombre completo, email.
- Menor privilegio en todo acceso a recursos, APIs y datos.
- Validación de todo input externo antes de procesarlo.
- Sin dependencias nuevas sin justificación registrada en el PLAN aprobado.

---

## Estándar de Tests

- **Cobertura mínima:** <ej: 80% en capa de servicio>
- **Obligatorio:** unit tests para toda lógica nueva; integration tests si cambian contratos de API.
- **Los tests corren sin dependencias externas** (mockear lo necesario).
- **Regresión:** los tests existentes siguen pasando salvo cambio explícito de comportamiento aprobado en el PRD.

---

## Integraciones del Proyecto

> Qué sistemas de Sooft usa este proyecto. Determina qué validaciones aplican.

| Integración | Estado | Notas |
|-------------|--------|-------|
| el issue tracker | <configurada / no aplica> | <tipo de tickets que recibe> |
| Repositorio (Git) | <configurada / no aplica> | <rama target, convención de ramas> |
| <otra> | | |

---

## Historial de Cambios

| Fecha | Autor | Cambio | Motivo |
|-------|-------|--------|--------|
| <YYYY-MM-DD> | <owner> | Versión inicial | Definición de principios del proyecto |
