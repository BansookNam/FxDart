import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final txns = makeTxns();
  await bench(
    slug: 'category-rank',
    impl: 'fxdart',
    n: n,
    run: () {
      final ranked = fx(txns)
          .filter((t) => t.date.startsWith('2026-07'))
          .groupedBy((t) => t.category)
          .map((g) =>
              (g.key, fx(g.items).sumBy((t) => t.amount), g.items.length))
          .sortByDesc((c) => c.$2)
          .take(3)
          .toList();
      return ranked
          .map((r) => '${r.$1}:${r.$2.toStringAsFixed(2)}:${r.$3}')
          .join('|');
    },
  );
}
