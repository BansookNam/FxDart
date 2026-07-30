// Deterministic sensor trace shared verbatim by both sides (headline 8,000).
// Async case: the example's 10 ms inter-reading delay is dropped entirely
// (Stream.fromIterable), keeping the stream shape.
// n is rounded down to a multiple of the window size (4) so there is no
// partial window (the example's native side silently drops a partial
// buffer); the rounded count is what is reported to bench.
import '../../harness.dart';

final n = caseN(8000) ~/ 4 * 4;

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
