import 'package:collection/collection.dart';

class Tx {
  final String date;
  final String category;
  final double amount;
  const Tx(this.date, this.category, this.amount);
}

const txns = [
  Tx('2026-07-02', 'Food', 12.50),
  Tx('2026-07-04', 'Travel', 132.40),
  Tx('2026-07-06', 'Food', 43.20),
  Tx('2026-07-09', 'Utilities', 60.34),
  Tx('2026-07-11', 'Food', 18.90),
  Tx('2026-07-14', 'Travel', 89.60),
  Tx('2026-07-17', 'Utilities', 41.66),
  Tx('2026-07-21', 'Food', 9.80),
];

double meanSpend(List<Tx> ts) =>
    ts.fold(0.0, (sum, t) => sum + t.amount) / ts.length;

void main() {
  final byCategory = groupBy(txns, (Tx t) => t.category);
  final averages =
      byCategory.entries.map((kv) => (kv.key, meanSpend(kv.value)));
  final top = maxBy(averages, (c) => c.$2)!;
  print('Highest average spend: ${top.$1} '
      '(\$${top.$2.toStringAsFixed(2)} per transaction)');
}
