// Async case: 1M real awaits is infeasible, so the async cases measure the
// pipeline machinery over a large-but-finishable N with zero-length delays.
import '../../harness.dart';

final n = caseN(5000);

// The example enriches the top 3 of 8 merchants; scaled, the async stage
// enriches the top half so it does real work (concurrency limit stays 2).
final enrichCount = n ~/ 2;

class Merchant {
  final String name;
  final double total;
  const Merchant(this.name, this.total);
}

const _categories = [
  'Groceries', 'Utilities', 'Dining', 'Transport',
  'Entertainment', 'Health', 'Travel', 'Subscriptions',
];

// Totals are a bijection on [0, n*100) scaled to dollars, so every total is
// unique and the -total sort is tie-free on both sides.
final merchants = List<Merchant>.generate(
  n,
  (i) => Merchant('Merchant #$i', (100 + (i * 2654435761) % (n * 100)) / 100),
);

final directory = {
  for (var i = 0; i < n; i++)
    'Merchant #$i': _categories[i % _categories.length],
};
