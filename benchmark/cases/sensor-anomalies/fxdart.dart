import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final readings = makeReadings();
  await bench(
    slug: 'sensor-anomalies',
    impl: 'fxdart',
    n: n,
    run: () {
      final alerts = fx(sensors)
          .zip(readings)
          .filter((r) => r.$2 > threshold)
          .map((r) => '${r.$1}: ${r.$2.toStringAsFixed(1)} °C')
          .toList();
      return '${alerts.length}|${alerts.first}|${alerts.last}';
    },
  );
}
