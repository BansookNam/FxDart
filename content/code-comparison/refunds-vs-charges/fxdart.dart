import 'package:fxdart/fxdart.dart';

class Tx {
  final String date;
  final String merchant;
  final double amount; // negative = refund
  const Tx(this.date, this.merchant, this.amount);
}

const txns = [
  Tx('2026-07-03', 'Cafe Aroma', 12.50),
  Tx('2026-07-05', 'Web Store', 89.99),
  Tx('2026-07-09', 'Web Store', -89.99),
  Tx('2026-07-12', 'Noodle Bar', 18.90),
  Tx('2026-07-15', 'Airline', 240.00),
  Tx('2026-07-18', 'Airline', -120.00),
  Tx('2026-07-21', 'Green Grocer', 43.20),
  Tx('2026-07-24', 'Book Nook', -27.99),
];

String fmt(Tx t) => '${t.merchant} \$${t.amount.abs().toStringAsFixed(2)}';

void main() {
  final (refunds, charges) = fx(txns).partition((t) => t.amount < 0);
  print('refunds: ${fx(refunds).map(fmt).join(', ')}');
  print('charges: ${fx(charges).map(fmt).join(', ')}');
}
