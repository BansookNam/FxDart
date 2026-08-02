import 'package:fxdart/fxdart.dart';

class Tx {
  final String category;
  final int amount;
  const Tx(this.category, this.amount);
}

// August card transactions, in statement order.
const txns = [
  Tx('groceries', 42),
  Tx('transport', 7),
  Tx('groceries', 18),
  Tx('dining', 25),
  Tx('transport', 12),
  Tx('groceries', 9),
  Tx('dining', 31),
  Tx('transport', 4),
  Tx('dining', 16),
];

void main() {
  // groupedBy keeps the chain going: (key, items) records in first-seen
  // key order, no Map.entries re-entry.
  final totals = fx(txns)
      .groupedBy((t) => t.category)
      .map((g) => '${g.key}: ${fx(g.items).sumBy((t) => t.amount)}')
      .toList();

  totals.forEach(print);
}
