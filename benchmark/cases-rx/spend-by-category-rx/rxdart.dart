import 'package:rxdart/rxdart.dart';

import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final txns = makeTxns();
  await bench(
    slug: 'spend-by-category-rx',
    impl: 'rxdart',
    n: n,
    run: () async {
      final totals = await Stream.fromIterable(txns)
          .groupBy((t) => t.category)
          // groupBy emits a GroupedStream per new key; each one must be
          // folded, lifted back into a stream, and merged — and no total can
          // arrive before the source stream is done.
          .flatMap((group) => group
              .fold<int>(0, (sum, t) => sum + t.amount)
              .asStream()
              .map((total) => '${group.key}: $total'))
          .toList();
      // 8 fixed categories → joining is O(1)-ish.
      return totals.join('|');
    },
  );
}
