// Deterministic 1,000,000-transaction ledger shared verbatim by both sides.
// Merchant ids are drawn mod n/5 so the distinct-merchant density stays
// constant at every BENCH_N scale; the power-of-two LCG only reaches a
// quarter of those residues, so at the headline n the dedup set ends up at
// exactly 50,000 distinct merchants — still plenty to make first-occurrence
// dedup non-trivial.
import '../../harness.dart';

final n = caseN(1000000);
final _idSpace = n ~/ 5;

class Tx {
  final String date;
  final String merchant;
  final double amount;
  const Tx(this.date, this.merchant, this.amount);
}

List<Tx> makeTxns() {
  final rng = Lcg(4);
  return List.generate(n, (i) {
    final month = 1 + rng.nextInt(12);
    final day = 1 + rng.nextInt(28);
    return Tx(
      '2026-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}',
      'Merchant #${rng.nextInt(_idSpace)}',
      (100 + rng.nextInt(9900)) / 100,
    );
  });
}
