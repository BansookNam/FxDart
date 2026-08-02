// Deterministic n-probe health-check feed shared verbatim by both sides.
// Statuses arrive in runs — repeats of the current status with occasional
// transitions — so adjacent dedup has real work to do.
import '../../harness.dart';

final n = caseN(1000000);

const _statuses = ['ok', 'warn', 'error', 'degraded'];

List<String> makeFeed() {
  final rng = Lcg(14);
  var cur = 0;
  return List.generate(n, (i) {
    // ~15% of probes flip to a different status (high bits, see Lcg caution).
    if (rng.nextDouble() < 0.15) {
      cur = (cur + 1 + rng.nextInt(_statuses.length - 1)) % _statuses.length;
    }
    return _statuses[cur];
  });
}
