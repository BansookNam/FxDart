// Deterministic stock list shared verbatim by both sides. Async case:
// headline 4,000 items, Duration.zero delays, concurrency 3 (the example's).
import '../../harness.dart';

final n = caseN(4000);

class Stock {
  final String sku;
  final int qty;
  final double bookPrice;
  const Stock(this.sku, this.qty, this.bookPrice);
}

List<Stock> makeStock() {
  final rng = Lcg(11);
  return List.generate(n, (i) {
    return Stock(
      'SKU-$i',
      1 + rng.nextInt(50),
      (1000 + rng.nextInt(90000)) / 100,
    );
  });
}

/// The price service's deterministic knowledge: it does not know every
/// 7th-with-offset SKU (the example's "some SKUs miss" pattern).
double? livePriceForIndex(int id) =>
    id % 7 == 3 ? null : (100 + id % 500) / 10.0;

/// SKU → index (the service keys by SKU string, like the example).
int skuIndex(String sku) => int.parse(sku.substring(4));
