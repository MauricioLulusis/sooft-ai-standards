export type Transfer = {
  id: string;
  createdAt: string;
  amount: number;
};

export function listTransfers(transfers: Transfer[]): Transfer[] {
  return transfers;
}
