import 'package:rxdart/rxdart.dart';

class Tx {
  final String category;
  final int amount;
  const Tx(this.category, this.amount);
}

// August card transactions, in statement order.
const txns = [
  Tx('groceries', 42),
  Tx('transport', 7),
  Tx('groceries', 18),
  Tx('dining', 25),
  Tx('transport', 12),
  Tx('groceries', 9),
  Tx('dining', 31),
  Tx('transport', 4),
  Tx('dining', 16),
];

Future<void> main() async {
  final totals = await Stream.fromIterable(txns)
      .groupBy((t) => t.category)
      // groupBy emits a GroupedStream per new key; each one must be
      // folded, lifted back into a stream, and merged — and no total can
      // arrive before the source stream is done.
      .flatMap((group) => group
          .fold<int>(0, (sum, t) => sum + t.amount)
          .asStream()
          .map((total) => '${group.key}: $total'))
      .toList();

  totals.forEach(print);
}
