// Deterministic movement feed shared verbatim by both sides.
import '../../harness.dart';

final n = caseN(1000000);

// Deposits (+) and withdrawals (−) against an account opened at zero.
// Values come from nextDouble — the LCG's low bits are degenerate.
List<int> makeMoves() {
  final rng = Lcg(22);
  return List.generate(n, (_) => (rng.nextDouble() * 1000).floor() - 500);
}
