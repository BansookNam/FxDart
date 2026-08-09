import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final readings = makeReadings();
  await bench(
    slug: 'anomaly-context',
    impl: 'fxdart-fast',
    n: n,
    run: () {
      // Fast path: eager evaluation for multi-operator chain
      final context = fxFast(range(0, readings.length))
          .filter((i) => readings[i].temp > limit)
          .flatMap((i) => [i - 1, i, i + 1])
          .filter((i) => i >= 0 && i < readings.length)
          .uniq()
          .map((i) {
        final r = readings[i];
        final mark = r.temp > limit ? '!' : ' ';
        return '$mark ${r.time}  ${r.temp.toStringAsFixed(1)} C';
      });

      final peak = fx(readings).maxBy((r) => r.temp)!;
      return '${context.length}|${context.first}|${context.last}'
          '|Peak: ${peak.temp.toStringAsFixed(1)} C at ${peak.time}';
    },
  );
}
