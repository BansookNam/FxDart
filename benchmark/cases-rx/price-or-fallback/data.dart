// Deterministic purchase orders + promo price book shared verbatim by both
// sides. Async-shaped headline: 10,000 order lines.
//
// n lines grouped 5 per order; every 10th order is empty, exercising the
// defaultIfEmpty branch like the example's PO-3402 (empty orders replace
// their 5 lines, so total lines is slightly under n — the pipeline shape,
// not the exact count, is what scales). Lines with id % 7 == 3 have no
// entry in the promo book — the lookup throws and the list price is used —
// scaling the example's two-misses-of-five deterministically.
import '../../harness.dart';

final n = caseN(10000);

const linesPerOrder = 5;

final orderCount = n ~/ linesPerOrder;

double listPriceFor(int id) => (100 + (id * 37) % 2000) / 100;
double promoPriceFor(int id) => (50 + (id * 53) % 1500) / 100;

List<(String, List<({String sku, double list})>)> makeOrders() =>
    List.generate(orderCount, (o) {
      if (o % 10 == 9) return ('PO-$o', <({String sku, double list})>[]);
      return (
        'PO-$o',
        List.generate(linesPerOrder, (j) {
          final id = o * linesPerOrder + j;
          return (sku: 'SKU-$id', list: listPriceFor(id));
        })
      );
    });

Map<String, double> makePromoPrices() => {
      for (var id = 0; id < n; id++)
        if (id % 7 != 3) 'SKU-$id': promoPriceFor(id),
    };
