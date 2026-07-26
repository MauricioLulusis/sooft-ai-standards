# Prompt: Security Review

Prompt base para revisar cambios de código desde el ángulo de seguridad.
Más enfocado y profundo que la dimensión de seguridad del code review general. Usalo cuando el cambio toca autenticación, autorización, datos de clientes, integraciones externas o configuración de infraestructura.

---

## Cuándo usarlo

- Antes de mersooft cambios que tocan login, sesiones, tokens, permisos o roles.
- Cuando el cambio procesa o almacena datos personales (PII) de clientes.
- Cuando se agregan o modifican integraciones con sistemas externos.
- Cuando hay cambios en configuración, variables de entorno o secretos.
- Cuando el cambio es candidato a revisión por el equipo de seguridad de Sooft y querés anticipar hallazgos.

---

## Prompt

```
Hacé una revisión de seguridad del siguiente cambio de código. Trabajás en una organización (Sooft Technology). Los estándares de seguridad son estrictos: cualquier exposición de datos de clientes, secreto mal manejado o bypass de autorización es un incidente crítico.

CONTEXTO DEL CAMBIO:
---
DESCRIBÍ QUÉ HACE ESTE CAMBIO: ticket, funcionalidad, qué parte del sistema toca
---

CÓDIGO O DIFF A REVISAR:
---
PEGÁ EL CÓDIGO O EL DIFF COMPLETO
---

Revisá el código en las siguientes áreas de seguridad. Para cada hallazgo indicá:
- Área (ver abajo).
- Severidad: CRÍTICO | MEDIO | SUGERENCIA.
- Ubicación: archivo y línea si está disponible.
- Descripción del problema: qué está mal y por qué es un riesgo.
- Vector de ataque: cómo podría ser explotado.
- Corrección concreta: qué cambiar, con código si aplica.

Severidades:
- CRÍTICO: puede derivar en acceso no autorizado a cuentas, exposición de datos de clientes, ejecución remota de código, o bypass de controles de seguridad. Bloquea el MR y puede requerir notificación al equipo de seguridad.
- MEDIO: debilita la postura de seguridad sin ser directamente explotable, o es explotable sólo en condiciones específicas. Debe resolverse antes de mersooft.
- SUGERENCIA: mejora defensiva, hardening, o práctica recomendada que no es urgente pero reduce superficie de ataque.

Áreas de revisión:

### 1. Secretos y credenciales
¿Hay contraseñas, tokens, API keys, certificados o cualquier secreto hardcodeado en el código? ¿Se logean credenciales? ¿Se mandan credenciales en headers o querystrings que podrían quedar en logs?

### 2. Datos personales y PII
¿El código procesa, almacena o transmite datos personales de clientes (nombre, documento, teléfono, número de cuenta, saldo, datos de tarjeta)? ¿Están cifrados en tránsito y en reposo? ¿Se logean datos personales? ¿El acceso está restringido al mínimo necesario?

### 3. Autenticación y autorización
¿El endpoint o la función verifica que el usuario está autenticado? ¿Verifica que el usuario tiene permiso para acceder al recurso específico (autorización a nivel de objeto, no sólo de rol)? ¿Hay lógica que se puede saltear pasando parámetros manipulados?

### 4. Validación de inputs
¿Todos los datos de entrada (parámetros de URL, body JSON, headers, archivos) son validados y sanitizados antes de usarse? ¿Hay riesgo de SQL injection, LDAP injection, path traversal, o XSS? ¿Los tamaños y tipos de los inputs están acotados?

### 5. Manejo de errores y logging
¿Los errores exponen información técnica al cliente (stack traces, nombres de clases, queries SQL)? ¿Los logs incluyen información suficiente para auditoría sin incluir datos sensibles? ¿Los errores de autenticación/autorización devuelven el código HTTP correcto (401/403) sin revelar si el recurso existe?

### 6. Dependencias y librerías
¿Se agregan dependencias nuevas? ¿Tienen vulnerabilidades conocidas? ¿La versión usada es la más reciente del major compatible? ¿La librería es de origen confiable y tiene mantenimiento activo?

### 7. Configuración e infraestructura
¿Hay cambios en configuración de CORS, CSP, cabeceras de seguridad HTTP, o configuración de TLS? ¿Se habilita algún endpoint o funcionalidad que antes estaba deshabilitada? ¿Los archivos de configuración con secretos están en .gitignore?

---

Al final del análisis, incluí:

### Resumen de seguridad
- Total de hallazgos por severidad: X CRÍTICOS, X MEDIOS, X SUGERENCIAS.
- Veredicto: APROBADO | APROBADO CON CAMBIOS MENORES | REQUIERE REVISIÓN DE SEGURIDAD | RECHAZADO.
- Si hay hallazgos CRÍTICOS: indicá si el cambio requiere escalamiento al equipo de seguridad de Sooft antes de mersooft.
- Las 2 o 3 cosas más importantes a corregir.
```

---

## Ejemplo de uso

Entrada:

```java
@PostMapping("/transferencias")
public ResponseEntity<?> transferir(@RequestBody TransferenciaRequest req) {
    log.info("Transferencia solicitada: origen={}, destino={}, monto={}, token={}",
             req.getCuentaOrigen(), req.getCuentaDestino(), req.getMonto(), req.getToken());
    // ... lógica de negocio
}
```

Contexto: endpoint de transferencias bancarias, nuevo en este sprint.

Resultado esperado: el agente marca como CRÍTICO que el token se logea (exposición de credencial), como CRÍTICO que no hay verificación de que la cuenta origen pertenece al usuario autenticado (IDOR), y como MEDIO que los números de cuenta en los logs son PII que no deberían estar ahí sin enmascarar.

---

## Notas

- Este review no reemplaza la revisión formal del equipo de seguridad de Sooft para cambios de alto riesgo.
- Los hallazgos CRÍTICOS deben documentarse en el ticket del issue tracker antes de escalar.
- Para cambios en la capa de autenticación o en el manejo de tokens, coordiná siempre con el equipo de identidad/seguridad.
- Los números de cuenta, CBU, CUIL y datos de tarjeta son PII en el contexto regulatorio de Sooft: tratarlos siempre como datos sensibles.
