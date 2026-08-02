// Async case (#32 successes-and-failures): n async validations where a
// deterministic slice fails, split into successes and failures. Headline
// 10,000 — the RxDartComparison async family's headline scale; delays are
// Duration.zero, so the outcome-as-data plumbing is what is measured.
import '../../harness.dart';

final n = caseN(10000);

/// Order ids from the scaled import. Ids where id % 7 == 3 fail validation
/// — the deterministic stand-in for the example's two bad orders.
final orders = List<int>.generate(n, (i) => 1001 + i);
