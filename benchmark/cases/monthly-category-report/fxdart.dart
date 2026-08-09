import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final txns = makeTxns();
  await bench(
    slug: 'monthly-category-report',
    impl: 'fxdart',
    n: n,
    run: () {
      final byCategory = fx(txns)
          .filter((t) => t.date.startsWith('2026-07'))
          .foldBy((t) => t.category, 0.0, (sum, t) => sum + t.amount);
      // The example joins the formatted rows; the checksum stays O(1) instead
      // of embedding all 250 lines.
      final lines = fx(byCategory.entries)
          .map((kv) => (kv.key, kv.value))
          .sortBy((row) => -row.$2)
          .map((row) => '${row.$1}: \$${row.$2.toStringAsFixed(2)}')
          .toList();
      return '${lines.length}|${lines.first}|${lines.last}';
    },
  );
}
