import 'package:rxdart/rxdart.dart';

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
    impl: 'rxdart',
    n: n,
    run: () async {
      var lineCount = 0, listCount = 0, emptyCount = 0;
      var last = '';
      for (final (_, lines) in orders) {
        final quotes = await Stream.fromIterable(lines)
            // One error channel for the whole stream: by the time an
            // onErrorReturnWith after asyncMap saw the failure, the line that
            // caused it would be gone. Recovery that still knows its line
            // means wrapping each lookup in its own inner stream.
            .flatMap(
              (line) => Rx.fromCallable(() => promoPrice(line.sku))
                  .map((p) => '  ${line.sku}: ${p.toStringAsFixed(2)} (promo)')
                  .onErrorReturnWith(
                    (_, _) =>
                        '  ${line.sku}: ${line.list.toStringAsFixed(2)} (list)',
                  ),
            )
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
