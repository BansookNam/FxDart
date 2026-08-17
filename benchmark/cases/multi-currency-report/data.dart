// Deterministic 1,000,000-transaction multi-currency ledger shared verbatim
// by both sides. Category (6) and currency (4) cardinality stay bounded;
// record count scales. One transaction (index n ~/ 2) is a forced unique
// largest expense so max selection cannot tie at any scale.
import '../../harness.dart';

final n = caseN(1000000);

class Tx {
  final String date;
  final String category;
  final double amount;
  final String currency;
  const Tx(this.date, this.category, this.amount, this.currency);
}

const rates = {'USD': 1.0, 'EUR': 1.09, 'GBP': 1.27, 'JPY': 0.0063};

const _categories = ['Travel', 'Food', 'Lodging', 'Transit', 'Fun', 'Misc'];
const _currencies = ['USD', 'EUR', 'GBP', 'JPY'];

List<Tx> makeTxns() {
  final rng = Lcg(9);
  return List.generate(n, (i) {
    final day = 1 + rng.nextInt(28);
    final date = '2026-07-${day.toString().padLeft(2, '0')}';
    if (i == n ~/ 2) {
      return Tx(date, 'Lodging', 25000.00, 'USD'); // unique largest expense
    }
    // nextDouble-based draws: the LCG's low bits cycle, which would lock the
    // currency to a subset; the high bits are well distributed.
    final currency =
        _currencies[(rng.nextDouble() * _currencies.length).floor()];
    // JPY amounts are nominally ~150x larger, like real prices
    final amount = currency == 'JPY'
        ? (10000 + rng.nextInt(9990000)) / 100
        : (100 + rng.nextInt(49900)) / 100;
    final category =
        _categories[(rng.nextDouble() * _categories.length).floor()];
    return Tx(date, category, amount, currency);
  });
}
