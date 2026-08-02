// Deterministic parsed-amounts feed shared verbatim by both sides.
import '../../harness.dart';

final n = caseN(1000000);

// ~20% of the lines failed to parse (null), mirroring the example's feed.
// Values come from nextDouble: this pipeline filters on parity, and the
// LCG's low bits (hence nextInt's parity) are degenerate.
List<int?> makeAmounts() {
  final rng = Lcg(11);
  return List.generate(
    n,
    (_) => rng.nextDouble() < 0.2 ? null : (rng.nextDouble() * 1000).floor(),
  );
}
