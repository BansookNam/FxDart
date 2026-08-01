import 'package:collection/collection.dart';

class Tx {
  final String date;
  final String category;
  final double amount;
  const Tx(this.date, this.category, this.amount);
}

const txns = [
  Tx('2026-06-28', 'Food', 31.00), // June spillover — not this month
  Tx('2026-06-30', 'Transport', 8.20), // June spillover — not this month
  Tx('2026-07-02', 'Food', 12.50),
  Tx('2026-07-03', 'Transport', 2.75),
  Tx('2026-07-05', 'Food', 43.20),
  Tx('2026-07-08', 'Fun', 15.00),
  Tx('2026-07-11', 'Food', 18.90),
  Tx('2026-07-14', 'Bills', 60.34),
  Tx('2026-07-19', 'Fun', 22.00),
  Tx('2026-07-21', 'Transport', 11.40),
  Tx('2026-07-25', 'Bills', 48.12),
  Tx('2026-07-28', 'Food', 9.80),
];

void main() {
  final byCategory = txns
      .where((t) => t.date.startsWith('2026-07'))
      .groupListsBy((t) => t.category);
  final ranked = byCategory.entries
      .map((e) =>
          (e.key, e.value.fold(0.0, (s, t) => s + t.amount), e.value.length))
      .sorted((a, b) => b.$2.compareTo(a.$2))
      .take(3);

  for (final (category, total, count) in ranked) {
    print('$category: \$${total.toStringAsFixed(2)} ($count purchases)');
  }
}
