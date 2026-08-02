import 'package:rxdart/rxdart.dart';

import '../../harness.dart';
import 'data.dart';

int sourceRuns = 0;

/// A side-effecting source — running it twice would double [sourceRuns].
Stream<int> readings() async* {
  sourceRuns++;
  yield* Stream.fromIterable(baseReadings);
}

Future<void> main() async {
  await bench(
    slug: 'tee-the-pipeline',
    impl: 'rxdart',
    n: n,
    run: () async {
      sourceRuns = 0;
      // Make the stream connectable: attach BOTH readers first, then
      // connect, so one subscription to the source feeds two reductions.
      final shared = readings().publish();
      final total = shared.fold<int>(0, (acc, r) => acc + r);
      final peak = shared.reduce((a, b) => a > b ? a : b);
      shared.connect();
      // The single-pass proof: sourceRuns is folded into the checksum.
      return 'total=${await total}|peak=${await peak}|runs=$sourceRuns';
    },
  );
}
