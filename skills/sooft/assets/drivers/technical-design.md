# Prompt: Diseño Técnico

Prompt base para diseñar la solución técnica a un problema dado.
Usalo después de tener el requerimiento analizado y antes de escribir código o armar el plan de tareas.

---

## Cuándo usarlo

- Cuando el requerimiento implica decisiones de arquitectura no triviales.
- Cuando hay más de una forma de resolver el problema y necesitás documentar por qué elegiste una.
- Como insumo para el paso `sooft-implementation-plan` del flujo SOOFT.
- Cuando el tech lead o el arquitecto pide un documento de diseño antes de aprobar el trabajo.

---

## Prompt

```
Diseñá la solución técnica para el siguiente problema. Trabajás en un contexto de desarrollo de software empresarial con stack Spring Boot / Java, Node.js y algunos frontends en React o Angular. El análisis estático (SAST/calidad) se ejecuta en el pipeline de CI.

PROBLEMA A RESOLVER:
---
PEGÁ ACÁ LA DESCRIPCIÓN DEL PROBLEMA O EL ANÁLISIS DE REQUERIMIENTO YA HECHO
---

Producí el diseño técnico con las siguientes secciones:

### 1. Resumen del problema técnico
Una o dos oraciones que describan qué hay que resolver desde el punto de vista técnico, sin repetir todo el requerimiento.

### 2. Restricciones y condicionantes
¿Qué limitaciones existen? Considerá: compatibilidad con sistemas existentes, restricciones de seguridad y compliance del dominio, límites de rendimiento, plazos, tecnologías fijas que no se pueden cambiar.

### 3. Alternativas consideradas
Para cada alternativa listá:
- Nombre o descripción corta.
- Cómo resuelve el problema.
- Ventajas.
- Desventajas.
- Por qué se descarta (si aplica).

Incluí al menos dos alternativas aunque una sea claramente inferior. Si sólo hay una opción razonable, explicá por qué.

### 4. Solución propuesta
Describí la alternativa elegida con suficiente detalle para que otro desarrollador pueda implementarla sin adivinar.
Incluí:
- Componentes que se crean o modifican (clases, servicios, tablas, endpoints, topics Kafka, etc.).
- Flujo de datos: de dónde viene la información, cómo se transforma, a dónde va.
- Contratos de API o esquemas de datos relevantes (aunque sean borradores).
- Cambios de configuración o infraestructura necesarios.

### 5. Impacto en sistemas existentes
¿Qué cambia en sistemas que ya están en producción? ¿Hay breaking changes? ¿Necesitás coordinación con otros equipos? ¿Hay que hacer migraciones de datos?

### 6. Estrategia de tests
¿Cómo se va a validar que la solución funciona? Mencioná qué tipo de tests aplican (unitarios, integración, contrato, e2e) y qué escenarios son críticos cubrir.

### 7. Riesgos técnicos
Listá los riesgos técnicos de la solución propuesta. Para cada uno indicá:
- Descripción del riesgo.
- Probabilidad: ALTA / MEDIA / BAJA.
- Impacto: ALTO / MEDIO / BAJO.
- Mitigación propuesta.

### 8. Puntos abiertos
¿Qué decisiones técnicas quedan pendientes? ¿Qué necesitás saber o validar antes de empezar a implementar?

### 9. Estimación de esfuerzo
Estimá el esfuerzo de implementación en días/persona. Desglosá por área si corresponde (backend, frontend, infra, tests). Aclará los supuestos de la estimación.
```

---

## Ejemplo de uso

Entrada:

> Agregar campo 'sucursal preferida' al perfil del cliente. El dato viene de una lista fija de sucursales cargada desde una API interna. El perfil está en un microservicio Spring Boot con PostgreSQL. La app mobile lo consume vía REST.

Resultado esperado: el agente propone al menos dos alternativas (ej: campo en la tabla de perfil vs. tabla separada de preferencias), elige una con justificación, describe el endpoint PATCH necesario, el cambio de schema, y advierte sobre la necesidad de migración para clientes existentes.

---

## Notas

- Si ya hiciste el análisis de requerimiento con `requirement-analysis.md`, pegá ese output como input de este prompt.
- El diseño técnico no tiene que ser el documento final: es un borrador para discutir con el equipo y el tech lead.
- Para cambios de arquitectura significativos, el output de este prompt puede usarse como base de un Architecture Decision Record (ADR).
