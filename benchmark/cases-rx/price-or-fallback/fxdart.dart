import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';

late Map<String, double> promoPrices;

Future<double> promoPrice(String sku) async {
  await Future<void>.delayed(Duration.zero); // example: 5 ms
  final price = promoPrices[sku];
  if (price == null) throw StateError('no promo price for $sku');
  return price;
}

Future<void> main() async {
  final orders = makeOrders();
  promoPrices = makePromoPrices();
  await bench(
    slug: 'price-or-fallback',
    impl: 'fxdart',
    n: n,
    run: () async {
      var lineCount = 0, listCount = 0, emptyCount = 0;
      var last = '';
      for (final (_, lines) in orders) {
        final quotes = await fx(lines)
            .toAsync()
            // Recovery is plain control flow inside the callback: catch the
            // typed error right beside the call, return the fallback value.
            .map((line) async {
              try {
                final p = await promoPrice(line.sku);
                return '  ${line.sku}: ${p.toStringAsFixed(2)} (promo)';
              } on StateError {
                return '  ${line.sku}: ${line.list.toStringAsFixed(2)} (list)';
              }
            })
            .defaultIfEmpty('  (no lines to quote)')
            .toList();
        for (final q in quotes) {
          if (q == '  (no lines to quote)') {
            emptyCount++;
          } else {
            lineCount++;
            if (q.endsWith('(list)')) listCount++;
          }
          last = q;
        }
      }
      return 'lines=$lineCount|list=$listCount|empty=$emptyCount|$last';
    },
  );
}
