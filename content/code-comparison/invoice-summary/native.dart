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
  final totals = <String, double>{};
  for (final l in items) {
    totals[l.category] = (totals[l.category] ?? 0) + l.qty * l.unitPrice;
  }
  final rows = totals.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  final total = items.fold(0.0, (sum, l) => sum + l.qty * l.unitPrice);
  print('Invoice by category:');
  print(rows
      .map((row) => '${row.key}: \$${row.value.toStringAsFixed(2)}')
      .join('\n'));
  print('Total: \$${total.toStringAsFixed(2)}');
}
