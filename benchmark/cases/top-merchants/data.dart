// Deterministic n-transaction ledger shared verbatim by both sides
// (headline 1,000,000; the runner also runs N=100 and N=10,000 via BENCH_N).
// Merchant cardinality is bounded (300) so the groupBy stays realistic:
// many rows per key, not one key per row. At small N fewer than 300 distinct
// merchants appear — fine, the top-5 totals stay well-defined.
import '../../harness.dart';

final n = caseN(1000000);

class Tx {
  final String date;
  final String merchant;
  final double amount;
  const Tx(this.date, this.merchant, this.amount);
}

final List<String> merchants =
    List.generate(300, (i) => 'Merchant ${i.toString().padLeft(3, '0')}');

List<Tx> makeTxns() {
  final rng = Lcg(1);
  return List.generate(n, (i) {
    final month = 1 + rng.nextInt(12);
    final day = 1 + rng.nextInt(28);
    return Tx(
      '2026-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}',
      merchants[rng.nextInt(merchants.length)],
      (100 + rng.nextInt(9900)) / 100,
    );
  });
}
