# Fixture

Código productivo con un bug reportado: `renderOrderSummary` en `src/order-summary.ts` no valida que el `customerId` recibido pertenezca al usuario autenticado — posible exposición del resumen de pedidos de otro cliente.
