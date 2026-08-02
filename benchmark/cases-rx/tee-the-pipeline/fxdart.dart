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
      // fork the SAME iterable object twice: both cursors share one
      // buffered pass over the source, in whatever order they read.
      final shared = readings();
      final total = fx(fork(shared)).sum();
      final peak = fx(fork(shared)).max();
      // The single-pass proof: sourceRuns is folded into the checksum.
      return 'total=$total|peak=$peak|runs=$sourceRuns';
    },
  );
}
