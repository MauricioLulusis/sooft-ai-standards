export interface OrderAuditEntry {
  orderId: string;
  status: string;
  changedAt: Date;
  changedBy: string;
}

export class AuditLogRepository {
  constructor(private readonly db: Database) {}

  async findByOrderId(orderId: string): Promise<OrderAuditEntry[]> {
    return this.db.query<OrderAuditEntry>(
      "SELECT order_id, status, changed_at, changed_by FROM order_audit_log WHERE order_id = ? ORDER BY changed_at ASC",
      [orderId],
    );
  }
}

interface Database {
  query<T>(sql: string, params: unknown[]): Promise<T[]>;
}
