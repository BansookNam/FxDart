// Deterministic n-transaction ledger shared verbatim by both sides (headline
// 1,000,000; the runner also runs N=100 and N=10,000 via BENCH_N).
// Category cardinality is bounded (200) so the groupBy stays realistic:
// thousands of rows per key at the headline N, fewer at small N — fine, the
// max-average checksum stays well-defined and its maximum unique.
import '../../harness.dart';

final n = caseN(1000000);

class Tx {
  final String date;
  final String category;
  final double amount;
  const Tx(this.date, this.category, this.amount);
}

final List<String> categories =
    List.generate(200, (i) => 'Category ${i.toString().padLeft(3, '0')}');

List<Tx> makeTxns() {
  final rng = Lcg(7);
  return List.generate(n, (i) {
    final month = 1 + rng.nextInt(12);
    final day = 1 + rng.nextInt(28);
    return Tx(
      '2026-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}',
      categories[rng.nextInt(categories.length)],
      (100 + rng.nextInt(9900)) / 100,
    );
  });
}
