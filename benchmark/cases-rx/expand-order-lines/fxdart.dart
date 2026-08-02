import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final orders = makeOrders();
  await bench(
    slug: 'expand-order-lines',
    impl: 'fxdart',
    n: n,
    run: () {
      final lines = fx(orders)
          .flatMap((o) => o.skus.map((sku) => (order: o.id, sku: sku)))
          .map((l) => '${l.order}/${l.sku}')
          .toList();
      return '${lines.length}|${lines.first}|${lines.last}|orders=${orders.length}';
    },
  );
}
