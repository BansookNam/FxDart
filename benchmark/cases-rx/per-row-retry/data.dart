// Async case (#29 per-row-retry): n import rows through a per-row retry
// under a 3-wide concurrency limit. Headline 10,000 — the RxDartComparison
// async family's headline scale; delays are Duration.zero, so the retry +
// concurrency machinery is what is measured.
import '../../harness.dart';

final n = caseN(10000);

/// Row id 1..n plus a derived name. Like the example's six-row batch, the
/// even ids hit a flaky endpoint that fails exactly once before succeeding.
final rows = List<(int, String)>.generate(n, (i) => (i + 1, 'r${i + 1}'));
