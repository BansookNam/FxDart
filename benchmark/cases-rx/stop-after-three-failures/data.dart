// Async case (#34 stop-after-three-failures): a probe feed that gives up
// after the third failure. Headline 10,000 — the RxDartComparison async
// family's headline scale; probes are Duration.zero.
//
// The give-up threshold (3) is the example's; a fixed failing set would cap
// the early exit at constant depth, so the failures are spread every
// n ~/ 3 probes — the third failure lands near the end of the feed and the
// measured work scales with n.
import '../../harness.dart';

final n = caseN(10000);

final failEvery = n ~/ 3;

final probeIds = List<int>.generate(n, (i) => i + 1);

bool isFailing(int id) => id % failEvery == 0;
