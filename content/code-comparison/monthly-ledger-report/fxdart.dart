import 'package:fxdart/fxdart.dart';

class Tx {
  final String date;
  final String category;
  final String merchant;
  final double amount;
  const Tx(this.date, this.category, this.merchant, this.amount);
}

const txns = [
  Tx('2026-07-01', 'Income', 'Payroll Inc', 2600.00),
  Tx('2026-07-02', 'Food', 'Cafe Aroma', 12.50),
  Tx('2026-07-03', 'Transport', 'Metro', 2.75),
  Tx('2026-07-05', 'Food', 'Green Grocer', 43.20),
  Tx('2026-07-08', 'Fun', 'Cinema', 15.00),
  Tx('2026-07-11', 'Food', 'Noodle Bar', 18.90),
  Tx('2026-07-15', 'Bills', 'Electric Co', 60.34),
  Tx('2026-07-19', 'Food', 'Cafe Aroma', 9.80),
  Tx('2026-07-21', 'Bills', 'Water Works', 28.10),
  Tx('2026-07-23', 'Transport', 'Taxi', 11.40),
];

String money(num n) => '\$${n.toStringAsFixed(2)}';

void main() {
  final spend = fx(txns).filter((t) => t.category != 'Income').toList();
  final total = fx(spend).sumBy((t) => t.amount);

  final catLines = fx(
          fx(spend).foldBy((t) => t.category, 0.0, (s, t) => s + t.amount).entries)
      .map((e) => (e.key, e.value))
      .sortBy((c) => -c.$2)
      .map((c) => '  ${c.$1.padRight(10)} ${money(c.$2)}');

  final merchantLines = fx(
          fx(spend).foldBy((t) => t.merchant, 0.0, (s, t) => s + t.amount).entries)
      .map((e) => (e.key, e.value))
      .sortBy((m) => -m.$2)
      .take(3)
      .zipWithIndex()
      .map((p) => '  ${p.$1 + 1}. ${p.$2.$1.padRight(13)}${money(p.$2.$2)}');

  print(join('\n', [
    'July 2026 ledger',
    'Total spent: ${money(total)}',
    '',
    'By category:',
    ...catLines,
    '',
    'Top merchants:',
    ...merchantLines,
  ]));
}
