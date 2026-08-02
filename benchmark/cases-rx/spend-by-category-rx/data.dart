// Deterministic transaction ledger shared verbatim by both sides.
// Key cardinality is small and fixed (8 categories) so the groupBy /
// groupedBy shape — few groups, many members each — matches the example.
import '../../harness.dart';

final n = caseN(1000000);

class Tx {
  final String category;
  final int amount;
  const Tx(this.category, this.amount);
}

const categories = [
  'groceries',
  'transport',
  'dining',
  'utilities',
  'health',
  'entertainment',
  'travel',
  'clothing',
];

List<Tx> makeTxns() {
  final rng = Lcg(15);
  return List.generate(n, (i) {
    // Category drawn from nextDouble (high bits) — nextInt(8) would use the
    // LCG's degenerate low bits.
    final category = categories[(rng.nextDouble() * categories.length).floor()];
    return Tx(category, 1 + rng.nextInt(200));
  });
}
