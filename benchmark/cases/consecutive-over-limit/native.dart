import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final readings = makeReadings();
  await bench(
    slug: 'consecutive-over-limit',
    impl: 'native',
    n: n,
    run: () {
      final alerts = <String>[];
      for (var i = 0; i + 2 < readings.length; i++) {
        final a = readings[i];
        final b = readings[i + 1];
        final c = readings[i + 2];
        if (a.ppm > 1000 && b.ppm > 1000 && c.ppm > 1000) {
          alerts.add('${a.hour}–${c.hour}');
        }
      }
      return '${alerts.length}|${alerts.first}|${alerts.last}';
    },
  );
}
