# SPEC — <título del cambio técnico>

> Este documento aplica solo a cambios complejos. Si el cambio es simple, saltearlo.

**Status:** Draft | In Review | Approved
**Ticket:** <TICKET-XXXXX o N/A>
**Autor:** <owner>
**Fecha:** <YYYY-MM-DD>
**Última actualización:** <YYYY-MM-DD>
**PRD:** [PRD — <título>](../feats/<slug>/PRD.md)

> **Regla de honestidad.** Si una decisión técnica depende de algo que todavía no sabés (versión de una librería, contrato de un servicio, capacidad de la infra), marcá el punto con `[NEEDS CLARIFICATION: <qué falta>]` en vez de asumir. La SPEC no se aprueba con marcadores abiertos.

> **Coherencia con el PRD.** Cada decisión de esta SPEC debe poder rastrearse a un requisito del PRD. Si encontrás algo en la SPEC que el PRD no pide, o un requisito del PRD que la SPEC no cubre, registralo — es una inconsistencia que hay que resolver antes de planificar.

---

## Arquitectura y Diseño

### Visión general

<Describir el enfoque técnico de alto nivel. Cómo encaja en la arquitectura existente. Qué componentes nuevos se crean y cuáles se modifican.>

### Diagrama de componentes

```
<Diagrama ASCII o referencia a diagrama externo.
Mostrar componentes principales y sus relaciones.>
```

### Flujo de datos

```
<Describir el flujo de datos principal: origen → transformaciones → destino.
Incluir sistemas externos si aplica.>
```

### Decisiones de diseño clave

- <Decisión 1 y su justificación breve>
- <Decisión 2 y su justificación breve>

---

## Modelo de Datos

> Completar solo si hay cambios en el modelo de datos.

### Entidades nuevas o modificadas

```
<Nombre de entidad>
  campo_1: tipo — descripción
  campo_2: tipo — descripción
  ...
```

### Esquema de base de datos / migraciones

```sql
-- Describir el DDL o la migración necesaria
-- Incluir índices relevantes
```

### Consideraciones de volumen y rendimiento

<Estimación de volumen de datos, frecuencia de acceso, índices necesarios.>

---

## API y Contratos

### Endpoints nuevos o modificados

#### <MÉTODO> <path>

**Request:**
```json
{
  "campo": "<tipo y descripción>"
}
```

**Response exitosa (2xx):**
```json
{
  "campo": "<tipo y descripción>"
}
```

**Errores esperados:**
| Código | Condición | Mensaje |
|--------|-----------|---------|
| 400 | <condición de error> | <mensaje> |
| 404 | <condición de error> | <mensaje> |
| 500 | <condición de error> | <mensaje> |

### Contratos de eventos (Kafka / mensajería)

**Topic:** `<nombre-del-topic>`
**Tipo de evento:** `<NombreEvento>`

```json
{
  "eventId": "<UUID>",
  "eventType": "<NombreEvento>",
  "timestamp": "<ISO-8601>",
  "payload": {
    "campo": "<tipo y descripción>"
  }
}
```

---

## Seguridad y Permisos

### Autenticación y autorización

<Describir mecanismo de autenticación requerido. Roles y permisos necesarios. Cambios en el modelo de permisos existente.>

### Consideraciones de datos sensibles

- **PII:** <si hay datos personales, cómo se protegen — no en logs, encriptación en reposo, etc.>
- **Secretos:** <cómo se manejan credenciales y secretos — vault, variables de entorno, etc.>
- **Auditoría:** <qué acciones se auditan y dónde se registran>

### Checklist de seguridad

- [ ] Sin secretos hardcodeados en el código
- [ ] Sin PII en logs
- [ ] Principio de menor privilegio aplicado
- [ ] Validación de input en todos los endpoints
- [ ] Manejo seguro de errores (sin stack traces en producción)

---

## Integraciones Externas

| Sistema | Tipo de integración | SLA / timeout | Manejo de fallos |
|---------|---------------------|---------------|------------------|
| <nombre> | REST / gRPC / Kafka / DB | <timeout esperado> | <circuit breaker / retry / fallback> |

### Contratos de integración

<Describir los contratos con cada sistema externo. Versiones de API, formato de mensajes, manejo de errores.>

---

## Rollout y Migración

### Estrategia de despliegue

<Describir cómo se despliega este cambio. Feature flags, despliegue gradual, blue/green, etc.>

### Plan de migración de datos

<Si hay migración de datos: paso a paso de cómo se ejecuta, cómo se valida, cómo se hace rollback.>

### Plan de rollback

<Cómo revertir el cambio si algo falla en producción. Pasos concretos.>

### Configuración de feature flags

| Flag | Valor por defecto | Condición de activación | Dueño |
|------|-------------------|-------------------------|-------|
| `<nombre-del-flag>` | false | <cuándo activar> | <equipo> |

---

## Alternativas Consideradas

### Alternativa A — <nombre>

**Descripción:** <qué propone esta alternativa>

**Pros:**
- <ventaja 1>
- <ventaja 2>

**Contras:**
- <desventaja 1>
- <desventaja 2>

**Por qué se descartó:** <razón>

---

### Alternativa B — <nombre>

**Descripción:** <qué propone esta alternativa>

**Pros:**
- <ventaja 1>

**Contras:**
- <desventaja 1>

**Por qué se descartó:** <razón>

---

## Riesgos y Mitigaciones

| ID | Riesgo | Probabilidad | Impacto | Mitigación |
|----|--------|--------------|---------|------------|
| R-001 | <descripción del riesgo> | Alta / Media / Baja | Alto / Medio / Bajo | <acción de mitigación> |
| R-002 | <descripción del riesgo> | Alta / Media / Baja | Alto / Medio / Bajo | <acción de mitigación> |

---

## Estrategia de Tests

### Unit tests

<Qué se va a unit testear. Cobertura mínima esperada. Casos de borde importantes.>

### Integration tests

<Qué integraciones se van a testear. Ambiente de testing. Datos de prueba necesarios.>

### Tests de performance

<Si aplica: qué escenarios de carga se van a probar. Herramientas. Umbrales de aceptación.>

### Tests de regresión

<Qué funcionalidad existente puede verse afectada. Cómo se valida que no se rompió nada.>

---

## Historial de Cambios

> Toda modificación a la SPEC después de su aprobación inicial se registra acá.

| Fecha | Autor | Cambio | Motivo |
|-------|-------|--------|--------|
| <YYYY-MM-DD> | <owner> | Versión inicial | Creación de la SPEC |
