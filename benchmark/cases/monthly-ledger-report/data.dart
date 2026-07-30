// Deterministic 1,000,000-transaction ledger shared verbatim by both sides.
// Category and merchant cardinality stay bounded (6 categories, 12 merchants)
// so the groupBys stay realistic; record count scales.
import '../../harness.dart';

final n = caseN(1000000);

class Tx {
  final String date;
  final String category;
  final String merchant;
  final double amount;
  const Tx(this.date, this.category, this.merchant, this.amount);
}

const _spendCategories = ['Food', 'Transport', 'Fun', 'Bills', 'Rent'];
const _spendMerchants = [
  'Cafe Aroma', 'Metro', 'Green Grocer', 'Cinema', 'Noodle Bar',
  'Electric Co', 'Taxi', 'Book Nook', 'Gym One', 'Corner Deli', 'Water Works',
];

List<Tx> makeTxns() {
  final rng = Lcg(3);
  return List.generate(n, (i) {
    final day = 1 + rng.nextInt(28);
    final date = '2026-07-${day.toString().padLeft(2, '0')}';
    if (i % 20 == 0) {
      return Tx(date, 'Income', 'Payroll Inc', (200000 + rng.nextInt(60000)) / 100);
    }
    return Tx(
      date,
      _spendCategories[rng.nextInt(_spendCategories.length)],
      _spendMerchants[rng.nextInt(_spendMerchants.length)],
      (100 + rng.nextInt(9900)) / 100,
    );
  });
}
