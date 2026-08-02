// The example's Rx side flattens with core Stream.expand — rxdart's
// flatMapIterable is for line lists that arrive as streams — so the
// rxdart import is unused here, exactly as in the example panel.
// ignore: unused_import
import 'package:rxdart/rxdart.dart';

import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final orders = makeOrders();
  await bench(
    slug: 'expand-order-lines',
    impl: 'rxdart',
    n: n,
    run: () async {
      final lines = await Stream.fromIterable(orders)
          .expand((o) => o.skus.map((sku) => (order: o.id, sku: sku)))
          .map((l) => '${l.order}/${l.sku}')
          .toList();
      return '${lines.length}|${lines.first}|${lines.last}|orders=${orders.length}';
    },
  );
}
