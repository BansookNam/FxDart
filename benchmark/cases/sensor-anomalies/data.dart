// Deterministic n-sensor telemetry snapshot shared verbatim by both sides
// (headline 1,000,000; the runner also runs N=100 and N=10,000 via BENCH_N):
// two parallel lists, as a telemetry API often returns them. Roughly a
// quarter of readings exceed the threshold, so the alerts list is non-empty
// at every scale (verified at N=100).
import '../../harness.dart';

final n = caseN(1000000);

const threshold = 90.0;

const _kinds = ['boiler', 'pump', 'vent', 'fan', 'duct'];

final List<String> sensors = List.generate(
  n,
  (i) => '${_kinds[i % _kinds.length]}-$i',
);

List<double> makeReadings() {
  final rng = Lcg(6);
  // Degrees C in [0, 120): roughly a quarter of readings exceed threshold.
  return List.generate(n, (i) => rng.nextDouble() * 120);
}
