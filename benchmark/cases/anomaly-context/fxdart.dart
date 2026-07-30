import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final readings = makeReadings();
  await bench(
    slug: 'anomaly-context',
    impl: 'fxdart',
    n: n,
    run: () {
      // materialized (the example spreads the lazy lines into print)
      final context = fx(readings)
          .zipWithIndex()
          .filter((p) => p.$2.temp > limit)
          .flatMap((p) => [p.$1 - 1, p.$1, p.$1 + 1])
          .filter((i) => i >= 0 && i < readings.length)
          .uniq()
          .map((i) {
        final r = readings[i];
        final mark = r.temp > limit ? '!' : ' ';
        return '$mark ${r.time}  ${r.temp.toStringAsFixed(1)} C';
      }).toList();

      final peak = fx(readings).maxBy((r) => r.temp)!;
      return '${context.length}|${context.first}|${context.last}'
          '|Peak: ${peak.temp.toStringAsFixed(1)} C at ${peak.time}';
    },
  );
}
