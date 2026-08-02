// The example's whole Rx pipeline is core Stream operators (skipWhile/map
// need nothing from rxdart) — that IS the finding on this page. The import
// stays to mirror the example's panel.
// ignore: unused_import
import 'package:rxdart/rxdart.dart';

import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final readings = makeReadings();
  await bench(
    slug: 'skip-warmup-readings',
    impl: 'rxdart',
    n: n,
    run: () async {
      // skipWhile drops only the LEADING low readings — once one reading
      // clears the threshold, later dips are real data and stay.
      final live = await Stream.fromIterable(readings)
          .skipWhile((r) => r < threshold)
          .map((r) => 'Live: ${r.toStringAsFixed(1)} °C')
          .toList();
      return '${live.length}|${live.first}|${live.last}';
    },
  );
}
