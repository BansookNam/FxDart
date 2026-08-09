import 'package:fxdart/fxdart.dart';

class Tx {
  final String date;
  final String category;
  final String merchant;
  final double amount;
  const Tx(this.date, this.category, this.merchant, this.amount);
}

const txns = [
  Tx('2026-07-02', 'Food', 'Green Grocer', 45.10),
  Tx('2026-07-04', 'Transport', 'Metro', 12.00),
  Tx('2026-07-06', 'Fun', 'Cinema', 18.00),
  Tx('2026-07-09', 'Food', 'Noodle Bar', 38.25),
  Tx('2026-07-12', 'Bills', 'Electric Co', 60.34),
  Tx('2026-07-15', 'Transport', 'Taxi', 9.50),
  Tx('2026-07-18', 'Fun', 'Arcade', 16.75),
  Tx('2026-07-21', 'Food', 'Cafe Aroma', 52.40),
  Tx('2026-07-25', 'Bills', 'Water Co', 29.99),
];

const budgets = {'Food': 120.0, 'Transport': 40.0, 'Fun': 30.0, 'Bills': 90.0};

void main() {
  final spent = fx(txns).foldBy((t) => t.category, 0.0, (sum, t) => sum + t.amount);
  final alerts = fx(spent.entries)
      .map((kv) => (kv.key, kv.value))
      .filter((row) => row.$2 > budgets[row.$1]!)
      .sortBy((row) => budgets[row.$1]! - row.$2) // most over first
      .map((row) => '${row.$1}: \$${row.$2.toStringAsFixed(2)} spent, '
          '\$${budgets[row.$1]!.toStringAsFixed(2)} budget '
          '(over by \$${(row.$2 - budgets[row.$1]!).toStringAsFixed(2)})')
      .join('\n');
  print('Over budget in July:');
  print(alerts);
}
