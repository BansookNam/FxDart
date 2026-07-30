import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final orders = makeOrders();
  await bench(
    slug: 'average-basket',
    impl: 'fxdart',
    n: n,
    run: () {
      final avg = fx(orders)
          .filter((o) => o.total > 100)
          .averageBy((o) => o.total);
      return avg.toStringAsFixed(2);
    },
  );
}
