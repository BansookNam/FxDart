// Deterministic battery-sample feed shared verbatim by both sides.
import '../../harness.dart';

final n = caseN(1000000);

// Voltage samples with ~1/3 dropped by the sensor (null), mirroring the
// example's feed.
List<double?> makeSamples() {
  final rng = Lcg(66);
  return List.generate(
    n,
    (_) => rng.nextDouble() < 1 / 3 ? null : 3.0 + rng.nextDouble() * 1.5,
  );
}
