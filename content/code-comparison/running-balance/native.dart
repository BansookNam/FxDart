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
  // No scan in core Dart: fold only returns the final value, so the
  // running state has to live in a mutable variable.
  var balance = 250.0;
  final lines = [
    '${'Opening balance'.padRight(15)} \$${balance.toStringAsFixed(2)}',
  ];
  for (final t in txns) {
    balance += t.amount;
    lines.add('${t.label.padRight(15)} \$${balance.toStringAsFixed(2)}');
  }
  print(lines.join('\n'));
}
