import 'package:fxdart/fxdart.dart';

class Tx {
  final String date;
  final String merchant;
  final double amount;
  const Tx(this.date, this.merchant, this.amount);
}

const txns = [
  Tx('2026-07-02', 'Cafe Aroma', 12.50),
  Tx('2026-07-03', 'Metro Card', 2.75),
  Tx('2026-07-05', 'Green Grocer', 43.20),
  Tx('2026-07-07', 'Cafe Aroma', 9.80),
  Tx('2026-07-11', 'Noodle Bar', 18.90),
  Tx('2026-07-14', 'Metro Card', 2.75),
  Tx('2026-07-19', 'Cafe Aroma', 11.20),
  Tx('2026-07-23', 'Green Grocer', 27.65),
];

void main() {
  // uniq keeps the FIRST occurrence of each merchant, by contract.
  final merchants = fx(txns).map((t) => t.merchant).uniq().toList();
  print(merchants.join(', '));
}
