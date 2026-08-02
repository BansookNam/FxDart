// Deterministic card feed shared verbatim by both sides.
import '../../harness.dart';

final n = caseN(1000000);

typedef Txn = ({String id, int amount});

const budget = 100;

// The first over-budget transaction sits at n*9~/10 — the early exit's
// trigger scales with n, so a bigger headline measures more pulling.
// Everything before (and after) it stays at or under the budget.
List<Txn> makeTxns() {
  final rng = Lcg(33);
  final trigger = n * 9 ~/ 10;
  return List.generate(n, (i) {
    final amount = i == trigger
        ? budget + 1 + (rng.nextDouble() * 100).floor()
        : (rng.nextDouble() * (budget + 1)).floor(); // 0..budget, never over
    return (id: 'T-${i + 1}', amount: amount);
  });
}
