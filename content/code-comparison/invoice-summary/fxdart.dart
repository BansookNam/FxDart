import 'package:fxdart/fxdart.dart';

class Line {
  final String product;
  final String category;
  final int qty;
  final double unitPrice;
  const Line(this.product, this.category, this.qty, this.unitPrice);
}

// Line items of order #4211, placed 2026-07-14.
const items = [
  Line('Wireless Mouse', 'Electronics', 2, 24.50),
  Line('USB-C Cable', 'Electronics', 3, 9.99),
  Line('Desk Mat', 'Office', 1, 32.00),
  Line('Notebook', 'Office', 4, 5.25),
  Line('Pen Set', 'Office', 2, 11.40),
  Line('Monitor Stand', 'Electronics', 1, 45.90),
  Line('Coffee Beans', 'Pantry', 2, 14.75),
];

void main() {
  final byCategory =
      fx(items).foldBy((l) => l.category, 0.0, (s, l) => s + l.qty * l.unitPrice);
  final rows = fx(byCategory.entries)
      .map((kv) => (kv.key, kv.value))
      .sortBy((row) => -row.$2)
      .map((row) => '${row.$1}: \$${row.$2.toStringAsFixed(2)}')
      .join('\n');
  final total = fx(items).sumBy((l) => l.qty * l.unitPrice);
  print('Invoice by category:');
  print(rows);
  print('Total: \$${total.toStringAsFixed(2)}');
}
