// Deterministic 1,000,000-transaction ledger shared verbatim by both sides.
import '../../harness.dart';

final n = caseN(1000000);

class Tx {
  final String date;
  final String category;
  final double amount;
  const Tx(this.date, this.category, this.amount);
}

const _categories = ['Food', 'Transport', 'Fun', 'Bills', 'Rent', 'Health'];

List<Tx> makeTxns() {
  final rng = Lcg(7);
  return List.generate(n, (i) {
    final month = 1 + rng.nextInt(12);
    final day = 1 + rng.nextInt(28);
    // Small-cardinality choice via nextDouble — Lcg low bits are degenerate.
    final cat = _categories[(rng.nextDouble() * _categories.length).floor()];
    return Tx(
      '2026-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}',
      cat,
      (100 + rng.nextInt(9900)) / 100,
    );
  });
}
