// Async case: a bounded-concurrency fetch handed to a stream consumer in
// pairs. The example's five orders with per-order delay maps scale to n
// orders with Duration.zero delays; the status map is built once here and
// shared verbatim by both sides.
import '../../harness.dart';

final n = caseN(10000);

const statusNames = ['shipped', 'packed', 'allocated', 'delayed', 'returned'];

final orderIds = List<String>.generate(n, (i) => 'A-${1000 + i}');

/// Status per order, keyed like the example's const map.
final statuses = () {
  final rng = Lcg(50);
  return {
    for (final id in orderIds) id: statusNames[rng.nextInt(statusNames.length)],
  };
}();

/// Small polynomial hash used for the order-independent checksum — with
/// zero delays a 2-wide completion-order pool may interleave differently
/// on each side, so the checksum sums per-line codes instead of sampling
/// positions.
int lineCode(String s) {
  var h = 7;
  for (final c in s.codeUnits) {
    h = (h * 31 + c) & 0x3fffffff;
  }
  return h;
}
