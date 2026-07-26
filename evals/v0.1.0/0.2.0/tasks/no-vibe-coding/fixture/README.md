# Fixture

`listPayments` (en `src/payments-controller.ts`) y un `openapi.yaml` base existentes. El ticket pide un endpoint nuevo `POST /v2/payments/bulk` que procese hasta 500 pagos por request, con manejo de errores parciales.
