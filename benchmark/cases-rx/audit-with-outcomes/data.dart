// Deterministic config lines shared verbatim by both sides.
//
// The example parses eight lines of which three fail; scaled, lines where
// i % 7 == 3 carry an unparseable value (the deterministic failure pattern
// from AUTHORING.md), everything else is a formula-derived integer.
//
// Sync-shaped headline 1,000,000. The rx side wraps EVERY line in its own
// inner stream (asyncExpand + Rx.fromCallable + onErrorReturn) — that is the
// example's whole point — but one 1M iteration still fits the 2 s budget
// (~1.6 s JIT), so the standard sync headline stands.
import '../../harness.dart';

final n = caseN(1000000);

const _badValues = ['four', '', 'n/a'];

List<String> makeLines() => List.generate(
  n,
  (i) => i % 7 == 3
      ? 'key$i=${_badValues[i % _badValues.length]}'
      : 'key$i=${(i * 37) % 10000}',
);
