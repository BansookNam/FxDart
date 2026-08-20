// The example's second spelling: `foldByOrSkip`, the strict form.
//
// A third bar, as on `recent-errors`, and for the same reason: the gap
// between two ways of writing the same pipeline is the point this page makes.
// The composable chain stays the headline — it is what the page teaches by
// default.
import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final txns = makeTxns();
  await bench(
    slug: 'monthly-category-report',
    impl: 'fxdart_strict',
    n: n,
    run: () {
      final byCategory = fx(txns).foldByOrSkip(
        (t) => t.date.startsWith('2026-07') ? t.category : null,
        0.0,
        (sum, t) => sum + t.amount,
      );
      final lines = fx(byCategory.entries)
          .map((kv) => (kv.key, kv.value))
          .sortBy((row) => -row.$2)
          .map((row) => '${row.$1}: \$${row.$2.toStringAsFixed(2)}')
          .toList();
      return '${lines.length}|${lines.first}|${lines.last}';
    },
  );
}
