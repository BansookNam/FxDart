class Tx {
  final String date;
  final String category;
  final String merchant;
  final double amount;
  const Tx(this.date, this.category, this.merchant, this.amount);
}

const txns = [
  Tx('2026-06-28', 'Food', 'Green Grocer', 31.10),
  Tx('2026-06-30', 'Bills', 'Water Co', 24.00),
  Tx('2026-07-02', 'Food', 'Cafe Aroma', 12.50),
  Tx('2026-07-03', 'Transport', 'Metro', 2.75),
  Tx('2026-07-05', 'Food', 'Green Grocer', 43.20),
  Tx('2026-07-08', 'Fun', 'Cinema', 15.00),
  Tx('2026-07-11', 'Food', 'Noodle Bar', 18.90),
  Tx('2026-07-15', 'Bills', 'Electric Co', 60.34),
  Tx('2026-07-19', 'Transport', 'Taxi', 11.40),
  Tx('2026-07-23', 'Fun', 'Arcade', 8.25),
];

void main() {
  final totals = <String, double>{};
  for (final t in txns) {
    if (!t.date.startsWith('2026-07')) continue;
    totals[t.category] = (totals[t.category] ?? 0) + t.amount;
  }
  final rows = totals.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  print(rows
      .map((row) => '${row.key}: \$${row.value.toStringAsFixed(2)}')
      .join('\n'));
}
