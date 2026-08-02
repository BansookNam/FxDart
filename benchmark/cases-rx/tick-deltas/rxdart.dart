import 'package:rxdart/rxdart.dart';

import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final ticks = makeTicks();
  await bench(
    slug: 'tick-deltas',
    impl: 'rxdart',
    n: n,
    run: () async {
      final deltas = await Stream.fromIterable(ticks)
          .pairwise() // each tick with its predecessor, as a 2-element list
          .map((p) {
            final d = p.last - p.first;
            final sign = d >= 0 ? '+' : '';
            return '${p.first.toStringAsFixed(2)} -> '
                '${p.last.toStringAsFixed(2)}  $sign${d.toStringAsFixed(2)}';
          })
          .toList();
      return '${deltas.length}|${deltas.first}|${deltas.last}';
    },
  );
}
