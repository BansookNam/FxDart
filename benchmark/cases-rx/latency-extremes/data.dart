// Deterministic latency sample per endpoint, shared verbatim by both sides.
// Async-shaped example → headline caseN(10000); the extremes are forced
// unique at n-derived positions so min/max have one right answer.
import '../../harness.dart';

final n = caseN(10000);

final Map<String, int> samples = _makeSamples();

Map<String, int> _makeSamples() {
  final rng = Lcg(20);
  final m = <String, int>{};
  for (var i = 0; i < n; i++) {
    m['/e$i'] = 50 + rng.nextInt(900); // 50..949 ms
  }
  m['/e${n ~/ 3}'] = 12; // unique fastest
  m['/e${2 * n ~/ 3}'] = 5000; // unique slowest
  return m;
}
