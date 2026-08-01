import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';

String zone(double t) => t < 20 ? 'cool' : (t < 25 ? 'ok' : 'hot');

Future<void> main() async {
  final temps = makeTemps();
  await bench(
    slug: 'smoothed-zone-changes',
    impl: 'fxdart',
    n: n,
    run: () {
      final lines = fx(temps)
          .windowed(3)
          .map((w) => fx(w).average())
          .uniqAdjacentBy(zone)
          .pairwise()
          .map((p) => '${zone(p.$1)} → ${zone(p.$2)}'
              ' (avg ${p.$1.toStringAsFixed(1)} → ${p.$2.toStringAsFixed(1)})')
          .ifEmpty(() => ['stable — no zone changes'])
          .toList();
      return '${lines.length}|${lines.first}|${lines.last}';
    },
  );
}
