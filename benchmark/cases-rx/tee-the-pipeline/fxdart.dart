import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';

int sourceRuns = 0;

/// A side-effecting source — running it twice would double [sourceRuns].
Iterable<int> readings() sync* {
  sourceRuns++;
  yield* baseReadings;
}

Future<void> main() async {
  await bench(
    slug: 'tee-the-pipeline',
    impl: 'fxdart',
    n: n,
    run: () {
      sourceRuns = 0;
      // tee2 advances BOTH reductions on the same element, so one pass feeds
      // them both and nothing is ever buffered.
      final (total, peak) = tee2(
          readings(),
          (seed: 0, step: (int a, int r) => a + r),
          (seed: 0, step: (int a, int r) => r > a ? r : a));
      // The single-pass proof: sourceRuns is folded into the checksum.
      return 'total=$total|peak=$peak|runs=$sourceRuns';
    },
  );
}
