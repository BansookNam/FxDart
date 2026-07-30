// Deterministic n-transaction ledger shared verbatim by both sides (headline
// 1,000,000; the runner also runs N=100 and N=10,000 via BENCH_N).
// Roughly one transaction in four is a refund (negative amount), so both
// partitions are non-empty at every scale (verified at N=100).
import '../../harness.dart';

final n = caseN(1000000);

class Tx {
  final String date;
  final String merchant;
  final double amount; // negative = refund
  const Tx(this.date, this.merchant, this.amount);
}

const _merchants = [
  'Cafe Aroma', 'Web Store', 'Noodle Bar', 'Airline', 'Green Grocer',
  'Book Nook', 'Metro', 'Electric Co', 'Gym One', 'Corner Deli',
];

List<Tx> makeTxns() {
  final rng = Lcg(5);
  return List.generate(n, (i) {
    final month = 1 + rng.nextInt(12);
    final day = 1 + rng.nextInt(28);
    final amount = (100 + rng.nextInt(9900)) / 100;
    // nextDouble (high bits), not nextInt(4): the LCG's low two bits cycle
    // with period 4, which would make refunds exactly periodic.
    final refund = rng.nextDouble() < 0.25;
    return Tx(
      '2026-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}',
      _merchants[rng.nextInt(_merchants.length)],
      refund ? -amount : amount,
    );
  });
}
