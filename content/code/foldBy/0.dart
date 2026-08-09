import 'package:fxdart/fxdart.dart';

class Tx {
  const Tx(this.category, this.amount);
  final String category;
  final double amount;
}

void main() {
  const txns = [
    Tx('Food', 12.50),
    Tx('Transport', 2.75),
    Tx('Food', 43.20),
    Tx('Fun', 15.00),
    Tx('Food', 9.80),
  ];

  // Data-first form: key selector, seed, combining step, then the iterable.
  final spent = foldBy((Tx t) => t.category, 0.0, (sum, t) => sum + t.amount, txns);
  print(spent); // {Food: 65.5, Transport: 2.75, Fun: 15.0}

  // Chain form. Nothing is grouped on the way — each key holds only its
  // running total, so the memory is one accumulator per key, not per element.
  final longest = fx(['fig', 'kiwi', 'fx', 'plum', 'go', 'date'])
      .foldBy((w) => w.length, '', (best, w) => w.compareTo(best) > 0 ? w : best);
  print(longest); // {3: fig, 4: plum, 2: go}
}
