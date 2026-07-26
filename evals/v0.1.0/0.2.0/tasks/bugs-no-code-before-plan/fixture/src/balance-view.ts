export type BalanceView = {
  customerId: string;
  amount: number;
};

export function renderBalance(balance: BalanceView): string {
  return `${balance.customerId}: ${balance.amount}`;
}
