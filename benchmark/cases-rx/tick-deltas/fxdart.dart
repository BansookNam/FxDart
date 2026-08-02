import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final ticks = makeTicks();
  await bench(
    slug: 'tick-deltas',
    impl: 'fxdart',
    n: n,
    run: () {
      final deltas = fx(ticks)
          .pairwise() // each tick with its predecessor, as a (prev, next) record
          .map((p) {
            final d = p.$2 - p.$1;
            final sign = d >= 0 ? '+' : '';
            return '${p.$1.toStringAsFixed(2)} -> '
                '${p.$2.toStringAsFixed(2)}  $sign${d.toStringAsFixed(2)}';
          })
          .toList();
      return '${deltas.length}|${deltas.first}|${deltas.last}';
    },
  );
}
