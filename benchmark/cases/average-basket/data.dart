// Deterministic 1,000,000-order dataset shared verbatim by both sides.
import '../../harness.dart';

final n = caseN(1000000);

class Order {
  final String id;
  final String customer;
  final double total;
  const Order(this.id, this.customer, this.total);
}

const _customers = [
  'Ava', 'Ben', 'Cara', 'Dan', 'Elle', 'Finn', 'Gus', 'Hana',
];

List<Order> makeOrders() {
  final rng = Lcg(5);
  return List.generate(n, (i) {
    return Order(
      'A-${101 + i}',
      _customers[rng.nextInt(_customers.length)],
      // 1.00 .. 400.99 — roughly 3 in 4 orders clear the 100 filter.
      (100 + rng.nextInt(40000)) / 100,
    );
  });
}
