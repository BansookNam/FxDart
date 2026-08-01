// Deterministic order of line items shared verbatim by both sides.
// Async case: all delays are Duration.zero.
// Headline 100,000 — the async family's shared headline scale. It has to
// clear the runner's fixed N=10,000 pass, or the third set of bars on the
// page would just restate the second.
import '../../harness.dart';

final n = caseN(100000);

class Item {
  final String sku;
  final int qty;
  final double listPrice; // catalog fallback
  const Item(this.sku, this.qty, this.listPrice);
}

List<Item> makeItems() {
  final rng = Lcg(3);
  return List.generate(n, (i) {
    return Item(
      'SKU-$i',
      1 + rng.nextInt(5),
      (100 + rng.nextInt(19900)) / 100,
    );
  });
}

/// Deterministic "live pricing service" table stand-in: SKUs with
/// `id % 5 == 2` are missing from the live service (null -> fallback);
/// the rest get a formula-derived live price.
double? livePriceFor(String sku) {
  final id = int.parse(sku.substring(4));
  if (id % 5 == 2) return null;
  return (100 + (id * 37) % 12000) / 100;
}
