export function recordAudit(event: string, userId: string): void {
  console.log(`[audit] ${event} by ${userId}`);
}
