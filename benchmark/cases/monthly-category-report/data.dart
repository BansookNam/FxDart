// Deterministic n-transaction ledger shared verbatim by both sides.
// Category cardinality scales with n (250 at the headline 1,000,000 —
// ~4000 txns per category) so the groupBy stays realistic at every scale.
import '../../harness.dart';

final n = caseN(1000000);
final numCategories = (n ~/ 4000).clamp(5, 250);

class Tx {
  final String date;
  final String category;
  final String merchant;
  final double amount;
  const Tx(this.date, this.category, this.merchant, this.amount);
}

final List<String> categories = List.generate(
  numCategories,
  (i) => 'Cat-${(i + 1).toString().padLeft(3, '0')}',
);

const _merchants = [
  'Cafe Aroma',
  'Metro',
  'Green Grocer',
  'Cinema',
  'Noodle Bar',
  'Electric Co',
  'Taxi',
  'Water Co',
  'Arcade',
  'Corner Deli',
];

List<Tx> makeTxns() {
  final rng = Lcg(3);
  return List.generate(n, (i) {
    final month = 1 + rng.nextInt(12);
    final day = 1 + rng.nextInt(28);
    // Drawn from the Lcg's high bits (nextDouble): with an even number of rng
    // calls per record, nextInt's low-bit parity is fixed, and an even modulus
    // would make half the categories unreachable.
    final catIdx = (rng.nextDouble() * numCategories).floor();
    return Tx(
      '2026-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}',
      categories[catIdx],
      _merchants[rng.nextInt(_merchants.length)],
      (100 + rng.nextInt(9900)) / 100,
    );
  });
}
