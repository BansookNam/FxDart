// Async case: 1M real awaits is infeasible, so the async cases measure the
// pipeline machinery over a large-but-finishable N with zero-length delays.
import '../../harness.dart';

final n = caseN(10000);

final configNames = List<String>.generate(n, (i) => 'cfg-$i');

final configValues = {
  for (var i = 0; i < n; i++) 'cfg-$i': '{key: k$i, limit: ${i % 97}}',
};
