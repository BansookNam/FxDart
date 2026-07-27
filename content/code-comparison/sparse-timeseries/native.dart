import 'package:collection/collection.dart';

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
  final byDay = txns.groupListsBy((t) => t.day);
  final daily = [
    for (var d = 1; d <= 14; d++)
      (byDay[d] ?? const <Tx>[]).fold(0.0, (s, t) => s + t.amount),
  ];

  final weeks = <String>[];
  for (final (i, week) in daily.slices(7).indexed) {
    final start = i * 7 + 1;
    final cells = week.map((v) => v.toStringAsFixed(2)).join(' ');
    final total = week.fold(0.0, (s, v) => s + v);
    weeks.add('Jul ${dd(start)}-${dd(start + 6)}: $cells'
        '  | week total ${total.toStringAsFixed(2)}');
  }

  print([
    'Daily spend, July 1-14 (0.00 = no transactions)',
    ...weeks,
  ].join('\n'));
}
