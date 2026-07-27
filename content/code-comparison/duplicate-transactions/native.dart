class Tx {
  final String date;
  final String category;
  final String merchant;
  final double amount;
  const Tx(this.date, this.category, this.merchant, this.amount);
}

const txns = [
  Tx('2026-07-03', 'Food', 'Cafe Aroma', 12.50),
  Tx('2026-07-05', 'Transport', 'Metro', 2.75),
  Tx('2026-07-08', 'Food', 'Noodle Bar', 18.90),
  Tx('2026-07-08', 'Food', 'Noodle Bar', 18.90),
  Tx('2026-07-12', 'Bills', 'Electric Co', 60.34),
  Tx('2026-07-14', 'Food', 'Green Grocer', 43.20),
  Tx('2026-07-21', 'Fun', 'StreamFlix', 9.99),
  Tx('2026-07-21', 'Fun', 'StreamFlix', 9.99),
  Tx('2026-07-25', 'Transport', 'Taxi', 11.40),
  Tx('2026-07-27', 'Food', 'Cafe Aroma', 12.50),
];

void main() {
  final byKey = <String, List<Tx>>{};
  for (final t in txns) {
    byKey
        .putIfAbsent('${t.merchant}|${t.amount}|${t.date}', () => [])
        .add(t);
  }
  final lines = <String>[];
  for (final group in byKey.values) {
    if (group.length > 1) {
      for (final t in group) {
        lines.add(
            '${t.date}  ${t.merchant}  \$${t.amount.toStringAsFixed(2)}');
      }
    }
  }
  print('Possible duplicate charges:');
  print(lines.join('\n'));
}
