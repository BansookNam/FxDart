import 'package:collection/collection.dart';

import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final orders = makeOrders();
  await bench(
    slug: 'average-basket',
    impl: 'native',
    n: n,
    run: () {
      // package:collection adds .average on Iterable<num>.
      final avg = orders
          .where((o) => o.total > 100)
          .map((o) => o.total)
          .average;
      return avg.toStringAsFixed(2);
    },
  );
}
