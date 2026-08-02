// Deterministic daily-spend series (cents) shared verbatim by both sides.
//
// Full weeks only, like the example's 21 days — n is rounded down to a
// multiple of 7 (AUTHORING divisibility rule). Amounts span the example's
// 480–2210¢ range.
import '../../harness.dart';

final n = caseN(1000000) ~/ 7 * 7;

List<int> makeDailyCents() {
  final rng = Lcg(24);
  return List.generate(n, (_) => 480 + rng.nextInt(1731));
}
