import 'package:collection/collection.dart';

import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final txns = makeTxns();
  await bench(
    slug: 'category-rank',
    impl: 'native',
    n: n,
    run: () {
      final byCategory = txns
          .where((t) => t.date.startsWith('2026-07'))
          .groupListsBy((t) => t.category);
      final ranked = byCategory.entries
          .map(
            (e) => (
              e.key,
              e.value.fold(0.0, (s, t) => s + t.amount),
              e.value.length,
            ),
          )
          .sorted((a, b) => b.$2.compareTo(a.$2))
          .take(3)
          .toList();
      return ranked
          .map((r) => '${r.$1}:${r.$2.toStringAsFixed(2)}:${r.$3}')
          .join('|');
    },
  );
}
