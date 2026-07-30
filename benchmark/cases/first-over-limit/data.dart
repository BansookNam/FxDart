// Deterministic 1,000,000-reading series shared verbatim by both sides.
//
// The early exit is the point of this case: every reading before
// [spikeIndex] (90% into the list at every BENCH_N scale) stays at or below
// [limit], the reading AT spikeIndex is the first one over it, and the tail
// after it is mixed. Both sides therefore scan exactly spikeIndex + 1
// readings (900,001 at the headline n) and stop.
import '../../harness.dart';

final n = caseN(1000000);
const limit = 75.0;
final spikeIndex = n * 9 ~/ 10;

class Reading {
  final String time;
  final double celsius;
  const Reading(this.time, this.celsius);
}

List<Reading> makeReadings() {
  final rng = Lcg(6);
  return List.generate(n, (i) {
    final hour = (9 + i ~/ 60) % 24;
    final minute = i % 60;
    final time =
        '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
    final double celsius;
    if (i < spikeIndex) {
      celsius = 60 + rng.nextDouble() * 15; // [60, 75) — never over the limit
    } else if (i == spikeIndex) {
      celsius = 79.1; // the first reading over the limit
    } else {
      celsius = 55 + rng.nextDouble() * 30; // mixed tail, never examined
    }
    return Reading(time, celsius);
  });
}
