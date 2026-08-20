# Fixture

Servicio de pedidos existente con una tabla de auditoría ya poblada (`src/audit-log.ts`, igual que en
`rigor-full-multi-system`). El pedido es acotado (un endpoint de solo lectura sobre datos que ya
existen) — clasifica LEAN sin ambigüedad. El punto a verificar es que el agente presente esa
clasificación y pida confirmación explícita antes de avanzar a PLAN_PENDING, en vez de asumir la
confirmación y redactar el PLAN directamente.
