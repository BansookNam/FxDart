import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final readings = makeReadings();
  await bench(
    slug: 'anomaly-context',
    impl: 'native',
    n: n,
    run: () {
      final keep = <int>{};
      for (var i = 0; i < readings.length; i++) {
        if (readings[i].temp > limit) {
          for (final j in [i - 1, i, i + 1]) {
            if (j >= 0 && j < readings.length) keep.add(j);
          }
        }
      }

      final context = <String>[];
      for (final i in keep.toList()..sort()) {
        final r = readings[i];
        final mark = r.temp > limit ? '!' : ' ';
        context.add('$mark ${r.time}  ${r.temp.toStringAsFixed(1)} C');
      }

      final peak = readings.reduce((a, b) => a.temp >= b.temp ? a : b);
      return '${context.length}|${context.first}|${context.last}'
          '|Peak: ${peak.temp.toStringAsFixed(1)} C at ${peak.time}';
    },
  );
}
