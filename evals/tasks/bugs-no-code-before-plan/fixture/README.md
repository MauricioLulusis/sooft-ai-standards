# Fixture

Código productivo con un bug reportado: `renderBalance` en `src/balance-view.ts` no valida que el `customerId` recibido pertenezca al usuario autenticado — posible exposición del balance de otro cliente.
