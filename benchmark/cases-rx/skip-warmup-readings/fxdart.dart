import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final readings = makeReadings();
  await bench(
    slug: 'skip-warmup-readings',
    impl: 'fxdart',
    n: n,
    run: () {
      // dropWhile drops only the LEADING low readings — once one reading
      // clears the threshold, later dips are real data and stay.
      final live = fx(readings)
          .dropWhile((r) => r < threshold)
          .map((r) => 'Live: ${r.toStringAsFixed(1)} °C')
          .toList();
      return '${live.length}|${live.first}|${live.last}';
    },
  );
}
