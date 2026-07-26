# Fixture

`listOrders` (en `src/orders-controller.ts`) y un `openapi.yaml` base existentes. El ticket pide un endpoint nuevo `POST /v2/orders/bulk` que procese hasta 500 pedidos por request, con manejo de errores parciales.
