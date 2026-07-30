import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final readings = makeReadings();
  await bench(
    slug: 'weekly-sensor-averages',
    impl: 'fxdart',
    n: n,
    run: () {
      final lines = fx(readings)
          .chunk(7)
          .map((week) => fx(week).averageBy((t) => t))
          .zipWithIndex()
          .map((e) => 'Week ${e.$1 + 1}: ${e.$2.toStringAsFixed(1)}°C')
          .toList();
      return '${lines.length}|${lines.first}|${lines.last}';
    },
  );
}
