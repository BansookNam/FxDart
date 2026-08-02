import 'package:rxdart/rxdart.dart';

class Tx {
  final String date;
  final String category;
  final int amount;
  const Tx(this.date, this.category, this.amount);
}

// This month's card transactions — not a single travel line among them.
const txns = [
  Tx('2026-08-01', 'groceries', 42),
  Tx('2026-08-03', 'dining', 28),
  Tx('2026-08-05', 'groceries', 17),
  Tx('2026-08-08', 'utilities', 90),
  Tx('2026-08-11', 'dining', 33),
  Tx('2026-08-14', 'groceries', 25),
];

Future<void> main() async {
  final report = await Stream.fromIterable(txns)
      .where((t) => t.category == 'travel')
      .map((t) => '${t.date}  travel  ${t.amount}')
      .defaultIfEmpty('no travel spending recorded in August')
      .toList();

  report.forEach(print);
}
