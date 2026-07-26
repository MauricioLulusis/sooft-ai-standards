export type Order = {
  id: string;
  createdAt: string;
  amount: number;
};

export function listOrders(orders: Order[]): Order[] {
  return orders;
}
