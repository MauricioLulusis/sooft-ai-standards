# Prompt: Análisis de Requerimiento

Prompt base para analizar un requerimiento o ticket del issue tracker antes de comenzar cualquier tarea de desarrollo.
Usalo al inicio de un ticket nuevo para entender qué hay que hacer antes de escribir una línea de código.

---

## Cuándo usarlo

- Al recibir un ticket INC, RITM, CHG o REQ nuevo.
- Cuando el requerimiento es ambiguo o muy largo y necesitás desmenuzarlo.
- Como primer paso antes de correr `sooft-technical-spec` en el flujo SOOFT.

---

## Prompt

```
Analizá el siguiente requerimiento y producí un análisis estructurado.

REQUERIMIENTO:
---
PEGÁ ACÁ EL TEXTO DEL TICKET O LA DESCRIPCIÓN DEL REQUERIMIENTO
---

Producí el análisis en las siguientes secciones. Sé concreto: si algo no está claro, marcalo explícitamente en la sección de ambigüedades en vez de inventar una respuesta.

### 1. Objetivo de negocio
¿Qué problema resuelve o qué valor entrega este requerimiento? Una o dos oraciones, sin tecnicismos.

### 2. Alcance
¿Qué está dentro del alcance de este requerimiento? ¿Qué queda explícitamente fuera?
Listá ambas cosas aunque el requerimiento no lo diga explícitamente — inferí lo que puedas y marcá lo inferido con ⚠️.

### 3. Actores y usuarios afectados
¿Quiénes interactúan con lo que se va a construir o modificar? Incluí usuarios finales, sistemas externos y equipos internos.

### 4. Sistemas y componentes afectados
¿Qué sistemas, servicios, bases de datos, APIs o repositorios se ven involucrados? Si no está explícito, inferí en base al contexto y marcalo con ⚠️.

### 5. Reglas de negocio
Listá todas las reglas de negocio que el requerimiento impone. Numeralas. Si son implícitas, marcalas con ⚠️.

### 6. Criterios de aceptación
¿Cómo se valida que el requerimiento está cumplido? Si no están definidos en el ticket, proponé los mínimos razonables y marcalos con ⚠️ para que el equipo los confirme.

### 7. Ambigüedades y preguntas abiertas
Listá todo lo que no está claro, es contradictorio o falta en el requerimiento. Para cada punto indicá:
- Qué dice (o no dice) el requerimiento.
- Qué impacto tiene la ambigüedad si no se resuelve.
- Una pregunta concreta para hacerle al solicitante o al PO.

### 8. Riesgos y dependencias
¿Qué puede salir mal? ¿De qué depende este trabajo (otros equipos, sistemas, decisiones pendientes)?
Clasificá cada riesgo como ALTO / MEDIO / BAJO.

### 9. Resumen ejecutivo
3 a 5 oraciones que resuman qué hay que hacer, qué está claro y qué necesita resolverse antes de arrancar.
```

---

## Ejemplo de uso

Ticket de entrada:

> TICKET-2045 — "Agregar campo 'sucursal preferida' al perfil del cliente en la app mobile. El cliente lo puede modificar. Se usa para personalizar ofertas."

Resultado esperado: el agente identifica que no se especifica si el campo es obligatorio, qué sucursales son válidas (¿lista fija? ¿desde una API?), si hay que migrar datos existentes, y qué sistema de ofertas consume ese dato.

---

## Notas

- Si el ticket tiene adjuntos o referencias a otros tickets, incluílos en el bloque del requerimiento.
- Este análisis no reemplaza la validación con el solicitante: es un insumo para hacer preguntas mejores y más rápido.
- En el flujo SOOFT, el output de este prompt alimenta el paso `sooft-technical-spec`.
