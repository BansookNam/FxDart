// Deterministic transaction settlement day shared verbatim by both sides
// (headline 8,000). Async case: the bank-gateway posting delay is
// Duration.zero; the example's 2-wide posting window is kept.
// The merchant pool scales with n (n/16 = 500 at the headline) so the
// grouped/sorted posting phase stays sizeable at every scale.
import '../../harness.dart';

final n = caseN(8000);
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
