// Async case: zero-delay lookups, so the "distinct response times" of the
// example collapse — completion order becomes a scheduling detail. Both
// sides still run 3 lookups at a time and collect results in COMPLETION
// order; the checksum is order-independent (count + id sum) so the two
// sides agree regardless of interleave.
import '../../harness.dart';

final n = caseN(10000);

/// User ids 1..n, replacing the example's six-element list.
final ids = List<int>.generate(n, (i) => i + 1);
