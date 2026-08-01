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
    impl: 'native',
    n: n,
    run: () async {
      maxInFlight = 0;
      final repriced =
          List<({int qty, double price, bool fb})?>.filled(stock.length, null);
      var cursor = 0;
      Future<void> worker() async {
        while (cursor < stock.length) {
          final i = cursor++;
          final s = stock[i];
          final live = await livePrice(s.sku);
          repriced[i] =
              (qty: s.qty, price: live ?? s.bookPrice, fb: live == null);
        }
      }

      await Future.wait([worker(), worker(), worker()]);

      var total = 0.0;
      var fallbacks = 0;
      for (final r in repriced) {
        total += r!.qty * r.price;
        if (r.fb) fallbacks++;
      }
      return '${total.toStringAsFixed(2)}|fb=$fallbacks|max=$maxInFlight';
    },
  );
}
