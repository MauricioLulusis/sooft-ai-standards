# Security Findings

> Parte de `sooft-security-remediation`. No invocar directamente.

## Propósito

Documentar hallazgos de seguridad de forma auditable antes de decidir qué entra en scope.

## Cuándo usarlo

- `phase == REQUIREMENT_LOADED` con tipo `security`.
- Al entrar a `SECURITY_FINDINGS` desde `/review`.

## Entradas

- Reporte de seguridad (export de herramienta SAST, CVE, auditoría o reporte manual).
- Ticket el issue tracker si existe.

## Delegación a subagente Copilot CLI

Si estás en **Copilot CLI** y existe el custom agent `sooft-security-reviewer`, delegá la normalización y revisión read-only de hallazgos a ese subagente. El orquestador `sooft-security-remediation` conserva el registro auditable, no descarta findings sin motivo y no inicia remediación en esta fase.

Si el subagente no está disponible, seguí este recurso directamente.

## Output

`docs/security/{slug}/FINDINGS.md`:

| ID | Tipo | Severidad | Archivo / Línea | Descripción | Fuente | Estado |
|----|------|-----------|-----------------|-------------|--------|--------|
| F-01 | ... | CRÍTICO | ... | ... | ... | PENDIENTE |

Tipos: `VULNERABILITY`, `SECURITY_HOTSPOT`, `CVE`, `MISCONFIGURATION`, `HARDCODED_SECRET`,
`PII_IN_LOG`, `PRIVILEGE_ESCALATION`, `OTHER`.

No asumir que todos los hallazgos son válidos o están en scope: documentar todos, luego el
developer decide (paso `assets/security-scope.md`).

## Transición

`phase = FINDINGS_DOCUMENTED`, `last_step = security-findings`, `next_step = confirm-scope`.

## Qué NO hacer

- No asumir que todos los hallazgos son válidos.
- No remediar todavía.
- No descartar findings sin registrar motivo.
