// Deterministic transaction import queue shared verbatim by both sides
// (headline 6,000). Async case: the example's real rate-limit window
// (a 15 ms delay per batch) is replaced by Duration.zero — the structural
// machinery (batches of 3, one batch in flight at a time) is kept intact.
import '../../harness.dart';

final n = caseN(6000);

class Txn {
  final String id;
  final double amount;
  const Txn(this.id, this.amount);
}

List<Txn> makeTxns() {
  final rng = Lcg(5);
  return List.generate(n, (i) {
    return Txn('t-${(i + 1).toString().padLeft(5, '0')}',
        (100 + rng.nextInt(49900)) / 100);
  });
}
