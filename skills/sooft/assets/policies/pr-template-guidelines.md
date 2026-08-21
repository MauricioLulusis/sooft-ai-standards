# Lineamientos de PR Template — Sooft Technology

---

## Principio base

**PR como contrato de revisión:** cada Pull Request debe responder las cinco preguntas que cualquier reviewer necesita sin conversaciones adicionales:

- ¿Qué se hizo?
- ¿Por qué se hizo?
- ¿Cómo se prueba?
- ¿Qué impacto tiene?
- ¿Qué debe revisar especialmente el aprobador?

Un PR sin esta información genera revisiones superficiales, idas y vueltas y aprobaciones con conocimiento parcial del impacto. Meses después hace imposible entender qué cambió, por qué y cómo se validó sin leer todo el código.

---

## Template corporativo

El archivo listo para instalar en repos vive en `assets/templates/pull_request_template.md`.

```markdown
# Resumen

## Ticket / Requerimiento

- el issue tracker: `TICKET-XXXXX` _(el formato que use tu issue tracker)_

## Objetivo

Describir brevemente qué problema resuelve este cambio y cuál es el resultado esperado.

---

# Cambios Realizados

### Funcionales

- Cambio 1
- Cambio 2

### Técnicos

- Refactor realizado
- Nuevos componentes
- Ajustes de arquitectura
- Cambios en base de datos
- Dependencias agregadas o modificadas

---

# Consideraciones para el Reviewer

Aspectos específicos que merecen atención durante la revisión:

- Revisar estrategia de cache.
- Revisar compatibilidad hacia atrás.
- Validar criterios de negocio.
- Validar manejo de errores.

---

# Cómo Probar el Cambio

## Precondiciones

- Branch desplegada.
- Datos necesarios.
- Variables de entorno.

## Pasos para Reproducir

1. Ejecutar aplicación.
2. Navegar a...
3. Crear...
4. Modificar...
5. Validar...

## Resultado Esperado

Describir exactamente qué debe ocurrir.

---

# Checklist del Autor

- [ ] Código probado localmente
- [ ] Tests actualizados
- [ ] No existen secretos o credenciales
- [ ] Documentación actualizada
- [ ] Conventional Commits utilizados
- [ ] Se validó impacto en componentes relacionados

---

# Impacto

## Alcance

- [ ] Backend
- [ ] Frontend
- [ ] Mobile
- [ ] Base de Datos
- [ ] Infraestructura
- [ ] CI/CD

## Riesgo

- [ ] Bajo
- [ ] Medio
- [ ] Alto

## Breaking Changes

- [ ] No
- [ ] Sí (explicar)

---

# Evidencia

Adjuntar:

- Capturas de pantalla.
- Logs relevantes.
- Resultados de pruebas.
- Videos cortos si aplica.

---

# Información Adicional

Cualquier detalle que ayude a entender mejor el cambio:

- Decisiones de diseño.
- Limitaciones conocidas.
- Trabajo futuro.
```

---

## Secciones obligatorias

Un PR se considera completo si incluye todas estas secciones con contenido real (no los placeholders del template):

| Sección | Contenido mínimo esperado |
|---|---|
| Ticket / Requerimiento | Número de ticket del issue tracker, en el formato que use el proyecto (ej. `TICKET-XXXXX`) |
| Objetivo | Descripción del problema que resuelve y resultado esperado |
| Cambios Realizados | Al menos un ítem funcional o técnico con contenido real |
| Consideraciones para el Reviewer | Al menos un aspecto que merece atención específica |
| Cómo Probar el Cambio | Precondiciones + pasos reproducibles + resultado esperado |
| Impacto | Alcance (qué capas afecta) y nivel de riesgo marcados; Breaking Changes indicado |
| Evidencia | Al menos un artefacto adjunto (captura, log, resultado de prueba) |

## Secciones opcionales

- **Información Adicional** — solo si hay decisiones de diseño, limitaciones o trabajo futuro relevante para el reviewer.

---

## Detección del template en el repo

Durante el init, SOOFT busca el template corporativo en `.github/pull_request_template.md`.

Si no se detecta → instalar el template corporativo en esa ruta. El template instalado es `assets/templates/pull_request_template.md`. Es idempotente: si ya existe, no sobreescribir.

---

## Validación de completitud

Al validar un PR antes de abrirlo, verificar la presencia y contenido real de cada sección obligatoria. Reportar lo que falta:

```
⚠️ No se encontró ticket del issue tracker asociado.
⚠️ No se describieron pasos de validación.
⚠️ No se indicó impacto del cambio.
⚠️ No se adjuntó evidencia.
```

### Ítems bloqueantes (el PR no puede abrirse sin resolverlos)

- Sección Objetivo ausente o con solo el texto placeholder.
- Sin número de ticket del issue tracker asociado.
- Sin pasos para reproducir el cambio.
- Sin indicación de impacto (alcance y nivel de riesgo).

### Ítems no bloqueantes (advertir y documentar)

- Sección Información Adicional ausente (es opcional).
- Evidencia presente como texto descriptivo en vez de artefactos adjuntos (advertir que adjuntar es preferible).
- Breaking Changes no marcado explícitamente (advertir y pedir confirmación antes de continuar).

---

## Criterios de aceptación

| ID | Dado | SOOFT debe |
|---|---|---|
| CA-01 | Un repositorio sin template de PR | Detectarlo durante el init e instalar el template corporativo |
| CA-02 | Un repositorio con template incompleto | Detectarlo y señalar qué secciones faltan |
| CA-03 | Un PR creado | Validar presencia de Objetivo, Ticket del issue tracker, Cambios, Pasos de validación, Impacto y Evidencia |
| CA-04 | Un PR incompleto | Indicar exactamente qué información falta antes de abrir el PR |
| CA-05 | Un reviewer | El template provee información suficiente para comprender el cambio, reproducirlo, evaluar riesgos y aprobar o rechazar con fundamento |
