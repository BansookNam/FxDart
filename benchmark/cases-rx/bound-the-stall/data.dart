// Async case (#30 bound-the-stall): n zero-delay probe reads, each wrapped
// in the example's per-read timeout. Headline 10,000 — the RxDartComparison
// async family's headline scale. The limit is sized so it can NEVER fire
// against Duration.zero reads: the wrapper's shape is what is measured, not
// the stall, so every reading survives to the report on both sides.
import '../../harness.dart';

final n = caseN(10000);

/// Read indices, built once so neither side pays for the generate call.
final probeIndices = List<int>.generate(n, (i) => i);

/// n probe readings in the example's 20-something range.
final probeValues = _makeValues();

List<double> _makeValues() {
  final rng = Lcg(30);
  return List.generate(n, (_) => 20 + rng.nextInt(500) / 100);
}
