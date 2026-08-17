// Deterministic 1,000,000-transaction July ledger shared verbatim by both
// sides. Day cardinality stays bounded (a real month, days 1-28 spent, 29-31
// left as the trailing no-spend streak); record count scales.
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
  final rng = Lcg(1);
  return List.generate(n, (i) {
    // nextDouble-based draw: the LCG's low bits cycle, which would leave
    // most days untouched; the high bits are well distributed.
    final day = 1 + (rng.nextDouble() * 28).floor();
    return Tx(
      '2026-07-${day.toString().padLeft(2, '0')}',
      _categories[rng.nextInt(_categories.length)],
      _merchants[rng.nextInt(_merchants.length)],
      (100 + rng.nextInt(9900)) / 100,
    );
  });
}
