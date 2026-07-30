import 'package:collection/collection.dart';

import '../../harness.dart';
import 'data.dart';

double meanSpend(List<Tx> ts) =>
    ts.fold(0.0, (sum, t) => sum + t.amount) / ts.length;

Future<void> main() async {
  final txns = makeTxns();
  await bench(
    slug: 'top-category-average',
    impl: 'native',
    n: n,
    run: () {
      final byCategory = groupBy(txns, (Tx t) => t.category);
      final averages =
          byCategory.entries.map((kv) => (kv.key, meanSpend(kv.value)));
      final top = maxBy(averages, (c) => c.$2)!;
      return '${top.$1}|${top.$2.toStringAsFixed(2)}';
    },
  );
}
