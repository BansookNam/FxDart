import 'package:fxdart/fxdart.dart';

class Tx {
  final String date;
  final String merchant;
  final double amount;
  const Tx(this.date, this.merchant, this.amount);
}

const txns = [
  Tx('2026-07-02', 'Cafe Aroma', 12.50),
  Tx('2026-07-03', 'Metro Card', 34.00),
  Tx('2026-07-05', 'Green Grocer', 43.20),
  Tx('2026-07-08', 'Airline Ticket', 289.99),
  Tx('2026-07-11', 'Noodle Bar', 18.90),
  Tx('2026-07-15', 'Electric Co', 60.34),
  Tx('2026-07-19', 'New Headphones', 129.00),
  Tx('2026-07-23', 'Taxi', 11.40),
];

void main() {
  // sortBy is ascending — negate the key to sort largest-first.
  final top = fx(txns).sortBy((t) => -t.amount).take(3).toList();
  for (final t in top) {
    print('${t.merchant.padRight(15)} \$${t.amount.toStringAsFixed(2)}');
  }
}
