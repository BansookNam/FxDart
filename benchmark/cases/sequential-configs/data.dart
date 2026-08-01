// Async case: 1M real awaits is infeasible, so the async cases measure the
// pipeline machinery over a large-but-finishable N with zero-length delays.
//
// Headline is 100,000 rather than the usual async ceiling of ~10,000: this is
// the cheapest async case in the suite — one zero-delay await and a map lookup
// per element, no concurrency window, no retry bookkeeping — so 100k still
// finishes an iteration in ~0.4 s. It also has to clear 10,000, or the headline
// bar would duplicate the N=10,000 bar the runner already renders.
import '../../harness.dart';

final n = caseN(100000);

final configNames = List<String>.generate(n, (i) => 'cfg-$i');

final configValues = {
  for (var i = 0; i < n; i++) 'cfg-$i': '{key: k$i, limit: ${i % 97}}',
};
