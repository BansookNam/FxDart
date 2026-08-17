// Deterministic n-transaction ledger, sorted by date (as a ledger export
// would be), shared verbatim by both sides (headline 1,000,000; the runner
// also runs N=100 and N=10,000 via BENCH_N). Dates spread evenly over
// 2026-01-01 .. 2026-12-28 at every N — dayIndex is a fraction of n — so the
// window always covers roughly the middle two thirds and both the dropped
// prefix and the taken window scale with n.
import '../../harness.dart';

final n = caseN(1000000);

class Tx {
  final String date;
  final String merchant;
  final double amount;
  const Tx(this.date, this.merchant, this.amount);
}

const start = '2026-03-01';
const end = '2026-10-28';

const _merchants = [
  'Cafe Aroma',
  'Metro',
  'Green Grocer',
  'Cinema',
  'Noodle Bar',
  'Electric Co',
  'Taxi',
  'Book Nook',
  'Gym One',
  'Corner Deli',
];

List<Tx> makeTxns() {
  final rng = Lcg(3);
  return List.generate(n, (i) {
    // Nondecreasing day-of-year (12 months x 28 days) keeps the list sorted.
    final dayIndex = (i * 336) ~/ n;
    final month = dayIndex ~/ 28 + 1;
    final day = dayIndex % 28 + 1;
    return Tx(
      '2026-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}',
      _merchants[rng.nextInt(_merchants.length)],
      (100 + rng.nextInt(9900)) / 100,
    );
  });
}
