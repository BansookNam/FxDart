import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  await bench(
    slug: 'cursor-lifetime',
    impl: 'fxdart',
    n: n,
    run: () async {
      late final LedgerCursor cursor;

      // The bracket: the resource is acquired on the first pull, read
      // lazily, and released exactly once — after the last row, or right
      // before an error would propagate.
      final rows = await fxAsync(
        usingAsync(
          () => cursor = LedgerCursor(),
          (c) => toAsync(Iterable.generate(c.length, c.read)),
          (c) => c.close(),
        ),
      ).toList();

      return '${rows.length}|${rows.first}|${rows.last}'
          '|closed=${cursor.closed}';
    },
  );
}
