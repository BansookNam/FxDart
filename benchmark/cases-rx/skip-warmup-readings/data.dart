// Deterministic probe boot cycle shared verbatim by both sides.
import '../../harness.dart';

final n = caseN(1000000);

const threshold = 20.0;

// The probe reads low for the first n/10 readings (the warm-up), first
// clears the threshold right after, then mixes live readings with real
// dips below the threshold that must be kept.
List<double> makeReadings() {
  final rng = Lcg(44);
  final warm = n ~/ 10;
  return List.generate(n, (i) {
    if (i < warm) return 10.0 + rng.nextDouble() * 9.9; // always < 20.0
    if (i == warm) return threshold + rng.nextDouble() * 5.0; // first live
    return 15.0 + rng.nextDouble() * 10.0; // live, with kept dips
  });
}
