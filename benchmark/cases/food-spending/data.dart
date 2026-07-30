// Deterministic 1,000,000-transaction ledger shared verbatim by both sides.
import '../../harness.dart';

final n = caseN(1000000);

class Tx {
  final String date;
  final String category;
  final String merchant;
  final double amount;
  const Tx(this.date, this.category, this.merchant, this.amount);
}

const _categories = ['Food', 'Transport', 'Fun', 'Bills', 'Rent'];
const _merchants = [
  'Cafe Aroma', 'Metro', 'Green Grocer', 'Cinema', 'Noodle Bar',
  'Electric Co', 'Taxi', 'Book Nook', 'Gym One', 'Corner Deli',
];

List<Tx> makeTxns() {
  final rng = Lcg(1);
  return List.generate(n, (i) {
    final month = 1 + rng.nextInt(12);
    final day = 1 + rng.nextInt(28);
    return Tx(
      '2026-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}',
      _categories[rng.nextInt(_categories.length)],
      _merchants[rng.nextInt(_merchants.length)],
      (100 + rng.nextInt(9900)) / 100,
    );
  });
}
