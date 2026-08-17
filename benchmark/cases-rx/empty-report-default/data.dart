// Deterministic n-transaction card ledger shared verbatim by both sides.
// Not a single 'travel' line among them — the default must fire.
import '../../harness.dart';

final n = caseN(1000000);

class Tx {
  final String date;
  final String category;
  final int amount;
  const Tx(this.date, this.category, this.amount);
}

const _categories = [
  'groceries',
  'dining',
  'utilities',
  'transport',
  'entertainment',
];

List<Tx> makeTxns() {
  final rng = Lcg(10);
  return List.generate(n, (i) {
    final day = 1 + rng.nextInt(28);
    return Tx(
      '2026-08-${day.toString().padLeft(2, '0')}',
      _categories[rng.nextInt(_categories.length)],
      1 + rng.nextInt(199),
    );
  });
}
