import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final readings = makeReadings();
  await bench(
    slug: 'sensor-anomalies',
    impl: 'native',
    n: n,
    run: () {
      // Core Dart has no zip — pairing parallel lists means indexing by hand.
      final alerts = <String>[];
      for (var i = 0; i < sensors.length; i++) {
        final value = readings[i];
        if (value > threshold) {
          alerts.add('${sensors[i]}: ${value.toStringAsFixed(1)} °C');
        }
      }
      return '${alerts.length}|${alerts.first}|${alerts.last}';
    },
  );
}
