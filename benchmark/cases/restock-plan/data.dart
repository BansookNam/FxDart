// Deterministic inventory shared verbatim by both sides (headline 1M).
import '../../harness.dart';

final n = caseN(1000000);

class Item {
  final String name;
  final int stock;
  final int minStock;
  final int reorderQty;
  final double unitCost;
  const Item(
    this.name,
    this.stock,
    this.minStock,
    this.reorderQty,
    this.unitCost,
  );
}

// Budget derived from n so the running-total/takeWhile stage does real work
// (~8k ordered lines at the 1M headline, matching the old fixed 5,000,000)
// yet still stops partway through `needed` (~n/2 items) at every scale. The
// +2500 floor exceeds the most expensive possible single line
// (24 x $99.99 ~ $2400), so at least one line is always affordable at N=100.
final budget = n * 5.0 + 2500;

List<Item> makeItems() {
  final rng = Lcg(11);
  final minStock = n ~/ 2;
  return List.generate(n, (i) {
    // stock is a bijection on [0, n) (multiplier coprime to n), so every
    // deficit (stock - minStock) is unique. The deficit sort must be
    // tie-free: package:collection's sortedBy and fxdart's sortBy use
    // different sort algorithms and would order tied items differently.
    final stock = (i * 2654435761) % n;
    return Item(
      'SKU-$i',
      stock,
      minStock,
      1 + rng.nextInt(24),
      (100 + rng.nextInt(9900)) / 100,
    );
  });
}
