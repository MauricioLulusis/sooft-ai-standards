# Revisión de Seguridad Pre-PR

Esta revisión se ejecuta en el gate de code review (recurso `internal/sooft-code-review-gate.md` de `sooft`) del pipeline SOOFT, antes de abrir el MR/PR.
No reemplaza el análisis estático automático (SAST/calidad) — lo complementa. El análisis estático
detecta patrones conocidos automáticamente; esta revisión cubre el contexto de negocio que la
herramienta no puede inferir.

Si algún punto de esta revisión devuelve un hallazgo de severidad alta, el MR no puede
abrirse hasta que se resuelva.

---

## Secretos y credenciales

- [ ] No hay credenciales hardcodeadas en el código: contraseñas, API keys, tokens, client
      secrets, connection strings. Buscá en el diff cualquier string que parezca una clave
      o que esté asignado a variables con nombres como `password`, `secret`, `token`, `key`,
      `credential`.
- [ ] No hay credenciales en archivos de configuración que van al repositorio (`application.yml`,
      `application.properties`, `.env`). Los valores sensibles tienen que venir de variables
      de entorno o de un vault/config server.
- [ ] Los archivos de configuración de ejemplo (`.env.example`, `application-local.yml`) no
      contienen valores reales, solo placeholders como `<COMPLETAR>` o `changeme`.
- [ ] Los logs no imprimen valores sensibles. Revisá que los objetos que se loguean no
      tienen campos de tipo contraseña o token en su `toString()` o serialización.

---

## Datos personales (PII)

- [ ] Los datos personales de clientes (DNI, CUIL, nombre, dirección, teléfono, email,
      datos financieros) no se loguean en texto plano. Si es necesario loguear para
      diagnóstico, usá masking (ej: `****1234` para el último bloque de un número).
- [ ] Los datos personales no se exponen en URLs (query params o path params con DNI,
      número de cuenta, etc.). Tienen que ir en el body de la request.
- [ ] Si el cambio almacena datos personales en una base de datos nueva o en un campo nuevo,
      confirmá que ese almacenamiento está dentro del scope del tratamiento de datos
      aprobado para ese sistema.
- [ ] Los datos personales no se pasan a sistemas de terceros sin que esté explícitamente
      contemplado en los contratos y aprobaciones correspondientes.

---

## Autenticación

- [ ] Los endpoints nuevos o modificados están protegidos por el mecanismo de autenticación
      del sistema (OAuth2, JWT, sesión, etc.). Ningún endpoint nuevo queda sin autenticación
      salvo que sea explícitamente público y esté justificado.
- [ ] Si se agregan endpoints públicos (sin autenticación), están documentados y tienen
      rate limiting o algún mecanismo de protección contra abuso.
- [ ] No se debilita la configuración de autenticación existente: no se deshabilita
      verificación de firma de tokens, no se amplían tiempos de expiración sin justificación,
      no se agregan métodos de autenticación legacy.

---

## Autorización

- [ ] Cada endpoint o acción nueva tiene las verificaciones de autorización correctas: no
      solo "el usuario está autenticado" sino "este usuario tiene permiso para hacer esta
      operación sobre este recurso".
- [ ] No hay escalada de privilegios posible: un usuario con perfil básico no puede acceder
      a recursos de otro usuario ni a funcionalidad de administración.
- [ ] Si se implementa lógica de autorización custom (no basada en roles del sistema), está
      testeada con casos específicos: acceso permitido y acceso denegado.
- [ ] Los IDs de recursos en las requests (ej: `GET /cuentas/{id}`) se validan contra el
      usuario autenticado. No basta con que el ID exista — tiene que pertenecer al usuario
      que hace la request (IDOR check).

---

## Validación de inputs

- [ ] Todos los inputs que vienen de fuera del sistema (request body, query params, path
      params, headers, mensajes de colas) son validados antes de procesarse. No se asume
      que el input es correcto porque viene de un sistema "confiable".
- [ ] Las validaciones de tipos y rangos están presentes: si un campo es un número de cuenta
      de 11 dígitos, se valida que sea exactamente eso, no que sea un string cualquiera.
- [ ] No hay construcción de queries SQL o comandos de sistema a partir de inputs sin
      parametrización. Usá prepared statements o el ORM. Si ves concatenación de strings
      en una query, es un bloqueante.
- [ ] Si se procesa XML, YAML o JSON de fuentes externas, el parser está configurado para
      rechazar entidades externas (XXE) y no tiene límites deshabilitados.
- [ ] Los uploads de archivos (si aplica) validan tipo, tamaño y contenido. No se confía
      solo en el Content-Type declarado por el cliente.

---

## Manejo de errores

- [ ] Los errores no exponen información interna en las respuestas al cliente: stack traces,
      nombres de clases, queries SQL, rutas del filesystem, versiones de librerías.
- [ ] Los mensajes de error son informativos para el cliente legítimo pero no dan pistas
      útiles para un atacante (ej: "credenciales inválidas" en lugar de "usuario no existe"
      o "contraseña incorrecta" por separado).
- [ ] Los errores inesperados son capturados y devuelven un código HTTP apropiado (500 para
      errores internos, no 200 con body de error). Las excepciones no manejadas no llegan
      al cliente con el stack trace completo.

---

## Dependencias

- [ ] Las dependencias nuevas agregadas al `pom.xml`, `package.json` o equivalente no tienen
      vulnerabilidades conocidas de severidad alta o crítica. Verificá en el reporte del
      análisis estático o en la herramienta de análisis de dependencias del pipeline de CI.
- [ ] No se agregaron dependencias que no estén en el catálogo aprobado por la organización o que
      no hayan pasado por el proceso de homologación correspondiente.
- [ ] Las versiones de dependencias existentes no fueron degradadas (downgrade) a versiones
      con vulnerabilidades conocidas.

---

## Análisis estático (SAST / calidad)

- [ ] El análisis estático para la rama del MR/PR está en verde o los hallazgos están
      revisados y justificados. No se puede mersooft con issues de severidad `BLOCKER` o
      `CRITICAL` sin revisión explícita.
- [ ] Los security hotspots marcados por la herramienta fueron revisados uno por uno. Si se
      marcan como "revisados", tiene que haber una justificación escrita
      en el comentario del hotspot, no solo el cambio de estado.
- [ ] La cobertura de código no bajó respecto a la rama base. Si bajó, está justificado
      (ej: código de infraestructura que no es testeable).

---

## Registro de la revisión

```json
"security_review": {
  "status": "approved" | "approved_with_observations" | "rejected",
  "reviewed_by": "<legajo o nombre>",
  "reviewed_at": "<ISO 8601>",
  "static_analysis_status": "green" | "red_reviewed" | "pending",
  "findings": [
    {
      "severity": "critical" | "high" | "medium" | "low",
      "category": "secrets" | "pii" | "authn" | "authz" | "input_validation" | "error_handling" | "dependencies" | "other",
      "description": "<qué encontraste>",
      "resolution": "<cómo se resolvió o estado>"
    }
  ]
}
```

`"critical"` y `"high"` bloquean el MR. `"medium"` y `"low"` son observaciones que
deben quedar registradas.
