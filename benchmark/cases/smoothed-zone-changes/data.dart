// Deterministic temperature feed shared verbatim by both sides.
import '../../harness.dart';

final n = caseN(1000000);

/// Triangle wave sweeping 15.0 → 27.0 → 15.0 every 400 readings, so the
/// 3-reading moving average keeps crossing the cool/ok/hot borders and the
/// zone-change yield scales with n (~n/100 transitions).
List<double> makeTemps() {
  return List.generate(n, (i) {
    final pos = i % 400;
    final tri = pos < 200 ? pos : 400 - pos;
    return 15.0 + tri * 12.0 / 200.0;
  });
}
