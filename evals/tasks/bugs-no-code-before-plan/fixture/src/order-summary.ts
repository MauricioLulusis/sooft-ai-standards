export type OrderSummary = {
  customerId: string;
  orderCount: number;
};

export function renderOrderSummary(summary: OrderSummary): string {
  return `${summary.customerId}: ${summary.orderCount}`;
}
