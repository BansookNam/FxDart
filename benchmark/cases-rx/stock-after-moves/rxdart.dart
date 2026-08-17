import 'package:rxdart/rxdart.dart';

import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final moves = makeMoves();
  await bench(
    slug: 'stock-after-moves',
    impl: 'rxdart',
    n: n,
    run: () async {
      final lines = await Stream.fromIterable(moves)
          .scan<(String, int)>(
            (acc, m, _) => (m < 0 ? '$m' : '+$m', acc.$2 + m),
            ('start', start),
          )
          // scan's first emission is already the first fold — replay the
          // opening level with startWith.
          .startWith(('start', start))
          .map(
            (e) =>
                e.$2 < 0 ? '${e.$1}: ${e.$2} (backorder)' : '${e.$1}: ${e.$2}',
          )
          .toList();
      return '${lines.length}|${lines.first}|${lines[n ~/ 2]}|${lines.last}';
    },
  );
}
