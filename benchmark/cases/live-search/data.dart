// Deterministic keystroke trace shared verbatim by both sides
// (headline 6,000). Async case: the example's 10 ms inter-key and
// backend delays become Duration.zero / Stream.fromIterable; the shape is
// kept: some keys are too short (< 2 chars), many repeat (autorepeat), the
// pipeline dedupes, takes the first `takeN` fresh queries, and hits the
// backend once per taken query.
import '../../harness.dart';

final n = caseN(6000);
// First takeN distinct queries trigger a backend search. takeN = n/10 is
// deliberately conservative against the trace's distinct-query yield, which
// plateaus around ~1250 because the Lcg's nextInt(2500) does not reach the
// whole universe (measured: 92 distinct at n=100, 1245 at n=6000, 1252 at
// n=10000 vs takeN 10 / 600 / 1000). At every scale the take truncates
// mid-stream (the early exit stays load-bearing) and .first/.last never
// see an empty list.
final takeN = n ~/ 10;

/// The search corpus: prefix match target for [takeN] backend calls.
final titles = List<String>.generate(
    150, (j) => 'find ${(j * 17) % 2500} handbook');

/// Query universe: 2500 distinct well-formed queries.
String _query(int k) => 'find $k';

List<String> makeTyped() {
  final rng = Lcg(17);
  return List.generate(n, (i) {
    // ~1 in 10 keys is a lone first character (filtered out downstream);
    // the rest repeat heavily across a 2500-query universe (deduped).
    if (rng.nextInt(10) == 0) return 'f';
    return _query(rng.nextInt(2500));
  });
}
