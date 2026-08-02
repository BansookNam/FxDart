// Deterministic warehouse move stream, shared verbatim by both sides:
// n signed moves (+receipts, -shipments) around an opening level, so the
// running balance regularly dips below zero and hits the backorder branch.
import '../../harness.dart';

final n = caseN(1000000);

const start = 20;

List<int> makeMoves() {
  final rng = Lcg(21);
  return List.generate(n, (i) => rng.nextInt(201) - 100);
}
