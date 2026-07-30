// Deterministic temperature series shared verbatim by both sides.
// n is rounded down to a multiple of 7 (999999 = 7 * 142857 at the headline;
// 98 at BENCH_N=100, 9996 at BENCH_N=10000): every week is complete, matching
// the example's full-week data (native's sublist(w*7, w*7+7) would throw on a
// partial week). The rounded n is what both sides report to bench().
import '../../harness.dart';

final n = caseN(999999) ~/ 7 * 7;

List<double> makeReadings() {
  final rng = Lcg(5);
  return List.generate(n, (i) => 15 + rng.nextDouble() * 15);
}
