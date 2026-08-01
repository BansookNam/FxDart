// Deterministic transaction settlement day shared verbatim by both sides.
// Async case: the bank-gateway posting delay is Duration.zero; the
// example's 2-wide posting window is kept. The merchant pool scales with n
// (n/16 = 6,250 at the headline) so the grouped/sorted posting phase stays
// sizeable at every scale.
// Headline 100,000 — the async family's shared headline scale. It has to
// clear the runner's fixed N=10,000 pass, or the third set of bars on the
// page would just restate the second.
import '../../harness.dart';

final n = caseN(100000);
final merchantCount = n ~/ 16;

class Txn {
  final String id;
  final String merchant;
  final double amount;
  final String status; // captured | refund | failed
  const Txn(this.id, this.merchant, this.amount, this.status);
  double get signed => status == 'refund' ? -amount : amount;
}

const _statuses = ['captured', 'captured', 'captured', 'refund', 'failed'];

List<Txn> makeTxns() {
  final rng = Lcg(13);
  return List.generate(n, (i) {
    return Txn(
      't$i',
      'm${rng.nextInt(merchantCount).toString().padLeft(3, '0')}',
      (100 + rng.nextInt(29900)) / 100,
      _statuses[rng.nextInt(_statuses.length)],
    );
  });
}
