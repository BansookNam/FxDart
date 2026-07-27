import 'package:fxdart/fxdart.dart';

class Tx {
  final int day; // day of July 2026
  final double amount;
  const Tx(this.day, this.amount);
}

const txns = [
  Tx(1, 12.50),
  Tx(1, 4.20),
  Tx(3, 30.00),
  Tx(6, 8.75),
  Tx(8, 22.10),
  Tx(11, 5.60),
  Tx(11, 14.00),
  Tx(13, 9.90),
];

String dd(int d) => '$d'.padLeft(2, '0');

void main() {
  final byDay = fx(txns).groupBy((t) => t.day);
  final daily = fx(range(1, 15))
      .map((d) => fx(byDay[d] ?? const <Tx>[]).sumBy((t) => t.amount))
      .toList();

  final weeks = fx(daily).chunk(7).zipWithIndex().map((w) {
    final start = w.$1 * 7 + 1;
    final cells = join(' ', fx(w.$2).map((v) => v.toStringAsFixed(2)));
    final total = fx(w.$2).sumBy((v) => v);
    return 'Jul ${dd(start)}-${dd(start + 6)}: $cells'
        '  | week total ${total.toStringAsFixed(2)}';
  });

  print(join('\n', [
    'Daily spend, July 1-14 (0.00 = no transactions)',
    ...weeks,
  ]));
}
