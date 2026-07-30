// Deterministic 1,000,000-transaction ledger shared verbatim by both sides.
// Duplicates are injected deterministically (every 97th row repeats the one
// before it; at tiny N the period shrinks to n/3 so several duplicate pairs
// still exist); the merchant|amount|date keyspace (~33M) also yields a
// sprinkle of natural collisions, exactly like real duplicate-charge data.
import '../../harness.dart';

final n = caseN(1000000);

// Every _dupEvery-th row repeats the previous one. 97 at real scales; n/3 at
// tiny N so the flagged report stays long enough for the checksum windows.
final int _dupEvery = n ~/ 3 < 97 ? n ~/ 3 : 97;

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
  final rng = Lcg(2);
  final txns = <Tx>[];
  for (var i = 0; i < n; i++) {
    if (i % _dupEvery == 0 && i > 0) {
      txns.add(txns[i - 1]); // deterministic duplicate charge
      continue;
    }
    final month = 1 + rng.nextInt(12);
    final day = 1 + rng.nextInt(28);
    txns.add(Tx(
      '2026-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}',
      _categories[rng.nextInt(_categories.length)],
      _merchants[rng.nextInt(_merchants.length)],
      (100 + rng.nextInt(9900)) / 100,
    ));
  }
  return txns;
}
