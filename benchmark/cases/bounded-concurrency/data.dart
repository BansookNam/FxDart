// Async case: 1M real awaits is infeasible, so the async cases measure the
// pipeline machinery over a large-but-finishable N with zero-length delays.
import '../../harness.dart';

final n = caseN(5000);

final userIds = List<int>.generate(n, (i) => i + 1);
