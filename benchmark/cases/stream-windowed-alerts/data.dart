// Deterministic sensor trace shared verbatim by both sides.
// Async case: the example's 10 ms inter-reading delay is dropped entirely
// (Stream.fromIterable), keeping the stream shape.
// n is rounded down to a multiple of the window size (4) so there is no
// partial window (the example's native side silently drops a partial
// buffer); the rounded count is what is reported to bench.
// Headline 100,000 — the async family's shared headline scale. It has to
// clear the runner's fixed N=10,000 pass, or the third set of bars on the
// page would just restate the second.
import '../../harness.dart';

final n = caseN(100000) ~/ 4 * 4;

class Reading {
  final int second; // offset into the run
  final double c; // temperature in celsius
  const Reading(this.second, this.c);
}

List<Reading> makeSamples() {
  final rng = Lcg(11);
  return List.generate(n, (i) {
    // 60.00 .. 79.99 C, so some windows average above the 75.00 alert limit.
    return Reading(i, (6000 + rng.nextInt(2000)) / 100);
  });
}
