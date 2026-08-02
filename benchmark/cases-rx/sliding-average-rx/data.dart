// Deterministic n-reading temperature series shared verbatim by both sides.
import '../../harness.dart';

final n = caseN(1000000);

List<double> makeTemps() {
  final rng = Lcg(12);
  return List.generate(n, (i) => 15.0 + rng.nextDouble() * 15.0);
}
