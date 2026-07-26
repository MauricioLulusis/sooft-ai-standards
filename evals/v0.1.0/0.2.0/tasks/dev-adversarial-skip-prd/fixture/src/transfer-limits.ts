export type TransferLimit = {
  channel: "mobile" | "web";
  dailyLimit: number;
};

export const currentLimits: TransferLimit[] = [];
