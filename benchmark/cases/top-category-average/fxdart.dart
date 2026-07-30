import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';

double meanSpend(List<Tx> ts) =>
    ts.fold(0.0, (sum, t) => sum + t.amount) / ts.length;

Future<void> main() async {
  final txns = makeTxns();
  await bench(
    slug: 'top-category-average',
    impl: 'fxdart',
    n: n,
    run: () {
      final byCategory = fx(txns).groupBy((t) => t.category);
      final top = fx(byCategory.entries)
          .map((kv) => (kv.key, meanSpend(kv.value)))
          .maxBy((c) => c.$2)!;
      return '${top.$1}|${top.$2.toStringAsFixed(2)}';
    },
  );
}
