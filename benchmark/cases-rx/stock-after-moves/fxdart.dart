import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final moves = makeMoves();
  await bench(
    slug: 'stock-after-moves',
    impl: 'fxdart',
    n: n,
    run: () {
      final lines = fx(moves)
          // scan emits the seed first, so the opening level is line one.
          .scan((acc, m) => (m < 0 ? '$m' : '+$m', acc.$2 + m),
              ('start', start))
          .map((e) =>
              e.$2 < 0 ? '${e.$1}: ${e.$2} (backorder)' : '${e.$1}: ${e.$2}')
          .toList();
      return '${lines.length}|${lines.first}|${lines[n ~/ 2]}|${lines.last}';
    },
  );
}
