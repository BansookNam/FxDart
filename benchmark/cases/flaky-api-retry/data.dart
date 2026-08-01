// Async case: 1M real awaits is infeasible, so the async cases measure the
// pipeline machinery over a large-but-finishable N with zero-length delays.
// Headline 100,000 — the async family's shared headline scale. It has to
// clear the runner's fixed N=10,000 pass, or the third set of bars on the
// page would just restate the second.
// The example polls ONE job until it is ready; scaled, we poll n jobs, each
// with the example's per-job pipeline (up to 10 attempts, serial polls).
import '../../harness.dart';

final n = caseN(100000);

final jobIds = List<int>.generate(n, (i) => i + 1);
