import 'package:collection/collection.dart';

class Tx {
  final String date;
  final String merchant;
  final double amount;
  const Tx(this.date, this.merchant, this.amount);
}

const txns = [
  Tx('2026-07-02', 'Cafe Aroma', 12.50),
  Tx('2026-07-03', 'Metro', 2.75),
  Tx('2026-07-05', 'Green Grocer', 43.20),
  Tx('2026-07-07', 'Cinema', 15.00),
  Tx('2026-07-09', 'Noodle Bar', 18.90),
  Tx('2026-07-11', 'Cafe Aroma', 9.80),
  Tx('2026-07-14', 'Electric Co', 60.34),
  Tx('2026-07-16', 'Book Nook', 27.99),
  Tx('2026-07-18', 'Metro', 3.25),
  Tx('2026-07-21', 'Noodle Bar', 21.10),
  Tx('2026-07-24', 'Green Grocer', 38.75),
  Tx('2026-07-26', 'Cafe Aroma', 14.20),
];

double total(List<Tx> ts) => ts.fold(0.0, (sum, t) => sum + t.amount);

void main() {
  final byMerchant = txns.groupListsBy((t) => t.merchant);
  final top = byMerchant.entries
      .sortedBy<num>((kv) => -total(kv.value))
      .take(5);
  for (final kv in top) {
    print('${kv.key}: \$${total(kv.value).toStringAsFixed(2)}');
  }
}
