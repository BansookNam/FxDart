import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final readings = makeReadings();
  await bench(
    slug: 'consecutive-over-limit',
    impl: 'fxdart',
    n: n,
    run: () {
      // Sliding window of 3: the list zipped with itself shifted by 1 and 2.
      final alerts = fx(readings)
          .zip(fx(readings).drop(1))
          .zip(fx(readings).drop(2))
          .map((w) => (w.$1.$1, w.$1.$2, w.$2))
          .filter((t) => t.$1.ppm > 1000 && t.$2.ppm > 1000 && t.$3.ppm > 1000)
          .map((t) => '${t.$1.hour}–${t.$3.hour}')
          .toList();
      return '${alerts.length}|${alerts.first}|${alerts.last}';
    },
  );
}
