export interface OrderSearchQuery {
  customerId: string;
  term?: string;
  dateFrom?: Date;
  dateTo?: Date;
}

export class OrdersSearchService {
  constructor(private readonly repository: OrdersRepository) {}

  async search(query: OrderSearchQuery): Promise<Order[]> {
    const all = await this.repository.findByCustomer(query.customerId);
    return all.filter((order) => {
      if (query.term && !order.description.includes(query.term)) return false;
      if (query.dateFrom && order.createdAt < query.dateFrom) return false;
      if (query.dateTo && order.createdAt > query.dateTo) return false;
      return true;
    });
  }
}

interface OrdersRepository {
  findByCustomer(customerId: string): Promise<Order[]>;
}

interface Order {
  id: string;
  description: string;
  createdAt: Date;
}
