// Deterministic n-transaction ledger + per-category budgets, shared verbatim
// by both sides. Category cardinality scales with n (250 at the headline
// 1,000,000 — ~4000 txns per category); budgets are drawn around the expected
// per-category spend (n / numCategories txns x ~$50.50 average, ±6%) so
// roughly half the categories end up over at every scale.
import '../../harness.dart';

final n = caseN(1000000);
final numCategories = (n ~/ 4000).clamp(5, 250);

// Expected per-category spend: (n / numCategories) txns x $50.50 average.
final _expectedSpend = n * 505 ~/ numCategories ~/ 10;

class Tx {
  final String date;
  final String category;
  final String merchant;
  final double amount;
  const Tx(this.date, this.category, this.merchant, this.amount);
}

final List<String> categories = List.generate(
    numCategories, (i) => 'Cat-${(i + 1).toString().padLeft(3, '0')}');

const _merchants = [
  'Green Grocer', 'Metro', 'Cinema', 'Noodle Bar', 'Electric Co',
  'Taxi', 'Arcade', 'Cafe Aroma', 'Water Co', 'Corner Deli',
];

Map<String, double> makeBudgets() {
  final rng = Lcg(7);
  final low = _expectedSpend * 94 ~/ 100;
  final range = _expectedSpend * 12 ~/ 100;
  return {
    for (final c in categories) c: (low + rng.nextInt(range)).toDouble(),
  };
}

List<Tx> makeTxns() {
  final rng = Lcg(8);
  return List.generate(n, (i) {
    final day = 1 + rng.nextInt(28);
    // Drawn from the Lcg's high bits (nextDouble): with an even number of rng
    // calls per record, nextInt's low-bit parity is fixed, and an even modulus
    // would make half the categories unreachable.
    final catIdx = (rng.nextDouble() * numCategories).floor();
    return Tx(
      '2026-07-${day.toString().padLeft(2, '0')}',
      categories[catIdx],
      _merchants[rng.nextInt(_merchants.length)],
      (100 + rng.nextInt(9900)) / 100,
    );
  });
}
