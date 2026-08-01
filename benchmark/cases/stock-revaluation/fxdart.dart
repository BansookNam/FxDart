import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';

int inFlight = 0;
int maxInFlight = 0;

Future<double?> livePrice(String sku) async {
  inFlight++;
  if (inFlight > maxInFlight) maxInFlight = inFlight;
  await Future<void>.delayed(Duration.zero);
  inFlight--;
  return livePriceForIndex(skuIndex(sku));
}

Future<void> main() async {
  final stock = makeStock();
  await bench(
    slug: 'stock-revaluation',
    impl: 'fxdart',
    n: n,
    run: () async {
      maxInFlight = 0;
      final repriced = await fx(stock)
          .toAsync()
          .attach((s) => livePrice(s.sku))
          .concurrent(3)
          .map((r) =>
              (qty: r.$1.qty, price: r.$2 ?? r.$1.bookPrice, fb: r.$2 == null))
          .toList();
      final total = fx(repriced).sumBy((r) => r.qty * r.price);
      final fallbacks = fx(repriced).countWhere((r) => r.fb);
      return '${total.toStringAsFixed(2)}|fb=$fallbacks|max=$maxInFlight';
    },
  );
}
