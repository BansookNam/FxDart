import 'package:fxdart/fxdart.dart';

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
  final byKey = fx(txns).groupBy((t) => '${t.merchant}|${t.amount}|${t.date}');
  final flagged = fx(byKey.values)
      .filter((group) => group.length > 1)
      .flatMap((group) => group) // every transaction involved, for review
      .map((t) => '${t.date}  ${t.merchant}  \$${t.amount.toStringAsFixed(2)}')
      .join('\n');
  print('Possible duplicate charges:');
  print(flagged);
}
