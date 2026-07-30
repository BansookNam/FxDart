import 'package:fxdart/fxdart.dart';

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

Future<void> main() async {
  final items = makeItems();
  await bench(
    slug: 'price-lookup-fallback',
    impl: 'fxdart',
    n: n,
    run: () async {
      maxInFlight = 0;
      final priced = await fx(items)
          .toAsync()
          .map((it) async => (it, await lookupPrice(it.sku)))
          .concurrent(3)
          .map((r) => (r.$1, r.$2 ?? r.$1.listPrice, r.$2 == null))
          .toList();
      final fallbacks = fx(priced).filter((r) => r.$3).size();
      final total = fx(priced).sumBy((r) => r.$2 * r.$1.qty);
      return '${priced.length}|fallbacks=$fallbacks'
          '|total=${total.toStringAsFixed(2)}|max=$maxInFlight';
    },
  );
}
