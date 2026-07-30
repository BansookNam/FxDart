import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final readings = makeReadings();
  await bench(
    slug: 'weekly-sensor-averages',
    impl: 'native',
    n: n,
    run: () {
      final lines = <String>[];
      for (var w = 0; w * 7 < readings.length; w++) {
        final week = readings.sublist(w * 7, w * 7 + 7);
        final avg = week.reduce((a, b) => a + b) / week.length;
        lines.add('Week ${w + 1}: ${avg.toStringAsFixed(1)}°C');
      }
      return '${lines.length}|${lines.first}|${lines.last}';
    },
  );
}
