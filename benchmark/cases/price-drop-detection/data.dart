// Deterministic 1,000,000-item June/July catalogs shared verbatim by both
// sides. Drop deltas are unique by construction ((i + 1) / 100), so the
// descending sort has no ties — the sorted order (and therefore the float
// summation order of `savings`) is identical regardless of sort stability.
// Prices come from plain formulas, so no Lcg is needed here.
import '../../harness.dart';

final n = caseN(1000000);

class Item {
  final String sku;
  final String name;
  final double price;
  const Item(this.sku, this.name, this.price);
}

double _junePrice(int i) => (i + 1) / 100 + 60 + (i % 977) / 100;

List<Item> makeJune() {
  return List.generate(n, (i) => Item('SKU-$i', 'Item $i', _junePrice(i)));
}

List<Item> makeJuly() {
  return List.generate(n, (i) {
    if (i % 50 == 7) {
      // new product this month — no June price to compare against
      return Item('SKU-N$i', 'New Item $i', 20 + (i % 400) / 10);
    }
    if (i % 3 == 0) {
      // price drop of exactly (i + 1) / 100 — unique per item
      return Item('SKU-$i', 'Item $i', _junePrice(i) - (i + 1) / 100);
    }
    if (i % 7 == 0) {
      return Item('SKU-$i', 'Item $i', _junePrice(i)); // unchanged
    }
    return Item('SKU-$i', 'Item $i', _junePrice(i) + 1.50); // price rise
  });
}
