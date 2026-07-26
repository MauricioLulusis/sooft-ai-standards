# Recurso interno de `sooft`: adr

> Recurso interno de la constitución `sooft` — **no es una skill invocable** ni un slash command. El agente lo carga leyendo este archivo (`sooft/internal/sooft-adr.md`) cuando el flujo lo pide. Regí siempre por la skill `sooft` (principios, gates de aprobación, máquina de estados y reglas no negociables).

## Propósito

Registrar decisiones de arquitectura importantes antes de implementarlas. Un ADR captura el contexto, las opciones evaluadas y la justificación de la decisión para que el equipo pueda entenderla y cuestionarla en el futuro.

## Cuándo crear un ADR

Crear un ADR cuando la decisión cumple al menos una de estas condiciones:

- Adoptar una nueva tecnología, librería o framework
- Cambiar un patrón de diseño consolidado en el proyecto
- Modificar el protocolo de comunicación entre servicios
- Tomar una decisión con trade-offs importantes y no obvios
- Decidir algo que será difícil o costoso de revertir
- Definir una convención que afecta a múltiples equipos

No crear un ADR para decisiones de implementación de bajo nivel o convenciones ya establecidas.

## Cuándo se crea

El ADR se redacta ANTES de empezar el desarrollo, no como documentación posterior. Su propósito es registrar el razonamiento en el momento de la decisión y permitir que el equipo la cuestione antes de comprometerse.

## Numeración

El número de ADR es secuencial dentro del proyecto. Verificar el último ADR en `docs/decisions/` antes de asignar el número.

## Dónde guardar

```
docs/decisions/ADR-{número}-{slug}.md
```

Ejemplos:
- `docs/decisions/ADR-001-uso-de-kafka-para-eventos.md`
- `docs/decisions/ADR-002-autenticacion-con-oauth2.md`

## Estructura del documento

La estructura canónica del ADR es la plantilla `skills/sooft/assets/templates/adr.md`. **Leéla y seguíla** como molde — no la reproduzcas acá. Cubre contexto, opciones consideradas (mínimo 2, con pros/contras), decisión, justificación, consecuencias (positivas/negativas/neutrales) y referencias al PRD/SPEC.

## Estados válidos

- **Propuesto:** redactado, pendiente de revisión del equipo.
- **Aceptado:** revisado y aprobado, guía la implementación.
- **Supersedido:** reemplazado por un ADR más reciente. Actualizar el campo "Supersede a" en el nuevo ADR y agregar una nota en el ADR viejo indicando cuál lo reemplaza.

## GATE

No aplica gate formal, pero el ADR debe estar en estado **Aceptado** antes de que la decisión que documenta se implemente.
