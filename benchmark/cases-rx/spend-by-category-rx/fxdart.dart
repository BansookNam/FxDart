import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final txns = makeTxns();
  await bench(
    slug: 'spend-by-category-rx',
    impl: 'fxdart',
    n: n,
    run: () {
      // groupedBy keeps the chain going: (key, items) records in first-seen
      // key order, no Map.entries re-entry.
      final totals = fx(txns)
          .groupedBy((t) => t.category)
          .map((g) => '${g.key}: ${fx(g.items).sumBy((t) => t.amount)}')
          .toList();
      // 8 fixed categories → joining is O(1)-ish.
      return totals.join('|');
    },
  );
}
