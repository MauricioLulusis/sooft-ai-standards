export type OrderLimit = {
  channel: "mobile" | "web";
  dailyLimit: number;
};

export const currentLimits: OrderLimit[] = [];
