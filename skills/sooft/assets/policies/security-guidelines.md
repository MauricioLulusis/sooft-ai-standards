# Lineamientos de Seguridad — Sooft Technology

---

## Principio base

**Security-by-default:** todo cambio pasa por validación y los controles de seguridad de Sooft, sin excepción.

---

## Reglas obligatorias

### Validación de input

- OBLIGATORIO validar todo input externo (HTTP, colas, archivos, payloads del issue tracker): tipo, formato y rango, antes de usarlo.
- OBLIGATORIO manejar excepciones sin exponer información interna al cliente: stack traces, queries SQL, rutas, nombres de clases/tablas, versiones de librerías. Al cliente: mensaje genérico + ID de correlación.

### Secretos

- PROHIBIDO hardcodear secretos en archivos versionados: passwords, tokens, API keys, certificados, connection strings.
- OBLIGATORIO usar el mecanismo oficial de secretos de Sooft.

### PII (Información Personal Identificable)

- PROHIBIDO loguear PII en cualquier nivel de log (DEBUG / INFO / WARN / ERROR).
- Datos considerados PII: DNI, CUIL, pasaporte, CBU, CVU, número de cuenta, PAN, CVV, vencimiento o nombre de tarjeta, password, PIN, pregunta secreta, token de sesión, JWT, cookie de autenticación.

### Privilegio y acceso a datos

- OBLIGATORIO principio de menor privilegio.
- OBLIGATORIO usar queries parametrizadas / prepared statements.
- PROHIBIDO concatenar strings para construir queries SQL.

### Criptografía

- PROHIBIDO implementar criptografía propia.
- Algoritmos aprobados: AES-256, BCrypt, SHA-256 o superior.
- PROHIBIDO deshabilitar validación SSL/TLS (`trustAllCertificates`, hostname verifier permisivo), aunque sea "para desarrollo".

### Dependencias nuevas

- OBLIGATORIO justificar dependencias nuevas en el PLAN/PR.
- OBLIGATORIO revisar CVEs de dependencias nuevas antes del merge.

---

## Procedimiento ante un hallazgo (orden obligatorio)

1. HALT de la implementación.
2. Describir: qué es, dónde está, cuál es el riesgo, cuál es la corrección posible.
3. Informar al developer.
4. Registrar en `.sooft/evidence.md` bajo `⚠️ Hallazgos de seguridad`.
5. Reanudar SOLO con confirmación explícita del developer.

El agente NUNCA aprueba excepciones de seguridad por su cuenta.

---

## Cambios que requieren revisión de Ciberseguridad antes del merge

- Auth / autorización / control de acceso.
- Nuevos endpoints públicos o semi-públicos.
- Manejo de sesiones, JWT o cookies.
- Integraciones externas nuevas.
- Cifrado en reposo o en tránsito.
- Procesamiento de tarjetas (PCI-DSS).
- Librerías de criptografía o identidad.
- Cambios de red o firewall.

---

## Trazabilidad del código generado por IA

- OBLIGATORIO marcar todo bloque generado por IA: `// [IA-generated] SOOFT — revisar antes de mersooft. Ticket: <TICKET-XXXXX>`.
- OBLIGATORIO revisión humana del código IA antes de abrir el PR.
- PROHIBIDO remover los marcadores `[IA-generated]` para ocultar el origen.
