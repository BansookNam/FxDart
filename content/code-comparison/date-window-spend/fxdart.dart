import 'package:fxdart/fxdart.dart';

class Tx {
  final String date;
  final String merchant;
  final double amount;
  const Tx(this.date, this.merchant, this.amount);
}

// Sorted by date, as a ledger export would be.
const txns = [
  Tx('2026-07-02', 'Cafe Aroma', 12.50),
  Tx('2026-07-04', 'Metro', 2.75),
  Tx('2026-07-08', 'Cinema', 15.00),
  Tx('2026-07-11', 'Noodle Bar', 18.90),
  Tx('2026-07-15', 'Electric Co', 60.34),
  Tx('2026-07-19', 'Cafe Aroma', 9.80),
  Tx('2026-07-23', 'Green Grocer', 43.20),
  Tx('2026-07-26', 'Book Nook', 27.99),
];

const start = '2026-07-08';
const end = '2026-07-21';

void main() {
  final total = fx(txns)
      .dropWhile((t) => t.date.compareTo(start) < 0)
      .takeWhile((t) => t.date.compareTo(end) <= 0)
      .sumBy((t) => t.amount);
  print('Spent $start to $end: \$${total.toStringAsFixed(2)}');
}
