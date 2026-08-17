// Deterministic transaction import queue shared verbatim by both sides.
// Async case: the example's real rate-limit window
// (a 15 ms delay per batch) is replaced by Duration.zero — the structural
// machinery (batches of 3, one batch in flight at a time) is kept intact.
// Headline 100,000 — the async family's shared headline scale. It has to
// clear the runner's fixed N=10,000 pass, or the third set of bars on the
// page would just restate the second.
import '../../harness.dart';

final n = caseN(100000);

class Txn {
  final String id;
  final double amount;
  const Txn(this.id, this.amount);
}

List<Txn> makeTxns() {
  final rng = Lcg(5);
  return List.generate(n, (i) {
    return Txn(
      't-${(i + 1).toString().padLeft(5, '0')}',
      (100 + rng.nextInt(49900)) / 100,
    );
  });
}
