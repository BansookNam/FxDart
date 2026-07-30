import '../../harness.dart';
import 'data.dart';

int inFlight = 0;
int maxInFlight = 0;

/// The live pricing service; some SKUs are missing from it (null).
Future<double?> lookupPrice(String sku) async {
  inFlight++;
  if (inFlight > maxInFlight) maxInFlight = inFlight;
  await Future<void>.delayed(Duration.zero);
  inFlight--;
  return livePriceFor(sku);
}

/// Worker pool: [limit] workers share a cursor, results keep input order.
Future<List<(Item, double, bool)>> priceAll(List<Item> all, int limit) async {
  final results = List<(Item, double, bool)?>.filled(all.length, null);
  var next = 0;
  Future<void> worker() async {
    while (next < all.length) {
      final i = next++;
      final live = await lookupPrice(all[i].sku);
      results[i] = (all[i], live ?? all[i].listPrice, live == null);
    }
  }

  await Future.wait([for (var i = 0; i < limit; i++) worker()]);
  return results.cast<(Item, double, bool)>();
}

Future<void> main() async {
  final items = makeItems();
  await bench(
    slug: 'price-lookup-fallback',
    impl: 'native',
    n: n,
    run: () async {
      maxInFlight = 0;
      final priced = await priceAll(items, 3);
      final fallbacks = priced.where((r) => r.$3).length;
      final total = priced.fold(0.0, (sum, r) => sum + r.$2 * r.$1.qty);
      return '${priced.length}|fallbacks=$fallbacks'
          '|total=${total.toStringAsFixed(2)}|max=$maxInFlight';
    },
  );
}
