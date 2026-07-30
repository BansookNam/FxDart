import 'package:collection/collection.dart';

import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final readings = makeReadings();
  await bench(
    slug: 'first-over-limit',
    impl: 'native',
    n: n,
    run: () {
      // Core skipWhile + package:collection's firstOrNull: a clean one-liner.
      final first = readings.skipWhile((r) => r.celsius <= limit).firstOrNull;
      return first == null
          ? 'No reading over ${limit.toStringAsFixed(1)} C'
          : 'First over ${limit.toStringAsFixed(1)} C: '
              '${first.time} at ${first.celsius.toStringAsFixed(1)} C';
    },
  );
}
