// Deterministic 1,000,000-transaction ledger shared verbatim by both sides.
import '../../harness.dart';

final n = caseN(1000000);

class Tx {
  final String date;
  final String merchant;
  final double amount;
  const Tx(this.date, this.merchant, this.amount);
}

const _merchants = [
  'Cafe Aroma',
  'Metro Card',
  'Green Grocer',
  'Airline Ticket',
  'Noodle Bar',
  'Electric Co',
  'New Headphones',
  'Taxi',
  'Book Nook',
  'Gym One',
];

List<Tx> makeTxns() {
  final rng = Lcg(3);
  return List.generate(n, (i) {
    final month = 1 + rng.nextInt(12);
    final day = 1 + rng.nextInt(28);
    // Amounts are made pairwise-distinct via an injective formula
    // (2654435761 is coprime to 1e8, so i -> i * 2654435761 mod 1e8 is
    // injective for any n <= 1e8 — every BENCH_N scale included). The top-3
    // therefore has no ties — List.sort is unstable, and a tie could
    // otherwise make the two sides disagree on which merchant ranks where.
    final cents = 1 + (i * 2654435761) % 100000000;
    return Tx(
      '2026-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}',
      _merchants[rng.nextInt(_merchants.length)],
      cents / 100,
    );
  });
}
