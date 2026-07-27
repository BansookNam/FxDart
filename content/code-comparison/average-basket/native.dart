import 'package:collection/collection.dart';

class Order {
  final String id;
  final String customer;
  final double total;
  const Order(this.id, this.customer, this.total);
}

const orders = [
  Order('A-101', 'Ava', 42.00),
  Order('A-102', 'Ben', 130.60),
  Order('A-103', 'Cara', 88.15),
  Order('A-104', 'Dan', 210.40),
  Order('A-105', 'Elle', 99.99),
  Order('A-106', 'Finn', 154.25),
  Order('A-107', 'Gus', 61.30),
  Order('A-108', 'Hana', 320.00),
];

void main() {
  // package:collection adds .average on Iterable<num>.
  final avg = orders
      .where((o) => o.total > 100)
      .map((o) => o.total)
      .average;
  print('Average large-order value: \$${avg.toStringAsFixed(2)}');
}
