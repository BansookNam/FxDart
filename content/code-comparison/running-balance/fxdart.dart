import 'package:fxdart/fxdart.dart';

class Tx {
  final String date;
  final String label;
  final double amount; // signed: deposits positive, spending negative
  const Tx(this.date, this.label, this.amount);
}

const txns = [
  Tx('2026-07-01', 'Salary', 2600.00),
  Tx('2026-07-02', 'Rent', -1150.00),
  Tx('2026-07-05', 'Green Grocer', -43.20),
  Tx('2026-07-09', 'Refund', 28.50),
  Tx('2026-07-14', 'Electric Co', -60.34),
  Tx('2026-07-21', 'Cafe Aroma', -9.80),
];

void main() {
  // scan emits its seed first — that becomes the opening-balance line.
  final lines = fx(txns)
      .scan((acc, t) => (t.label, acc.$2 + t.amount),
          ('Opening balance', 250.0))
      .map((e) => '${e.$1.padRight(15)} \$${e.$2.toStringAsFixed(2)}')
      .toList();
  print(lines.join('\n'));
}
