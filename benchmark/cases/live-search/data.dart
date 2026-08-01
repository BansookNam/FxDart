// Deterministic keystroke trace shared verbatim by both sides.
// Async case: the example's 10 ms inter-key and backend delays become
// Duration.zero / Stream.fromIterable; the shape is kept: some keys are too
// short (< 2 chars), many repeat (autorepeat), the pipeline dedupes, takes
// the first `takeN` fresh queries, and hits the backend once per taken query.
// Headline 100,000 — the async family's shared headline scale. It has to
// clear the runner's fixed N=10,000 pass, or the third set of bars on the
// page would just restate the second.
import '../../harness.dart';

final n = caseN(100000);

/// First [takeN] distinct queries trigger a backend search.
///
/// Everything here scales with n, including the query universe — this
/// pipeline is early-exit driven, so its cost is set by [takeN], not by the
/// trace length. A fixed universe would cap the distinct-query yield (the
/// Lcg's low bits reach only about half of `nextInt(u)`'s range), and past
/// that cap a larger n would drain the whole trace without ever reaching
/// [takeN] — the early exit, which is the thing being demonstrated, would
/// stop happening. With the universe tied to n the yield stays a fixed
/// fraction of n, so at every scale the take truncates mid-stream and
/// `.first`/`.last` never see an empty list. Measured distinct yield vs
/// takeN: 72/10 at n=100, 5,018/1,000 at n=10,000, 48,804/10,000 at the
/// headline — the take fires 11-15% of the way through the trace.
final takeN = n ~/ 10;

/// The search corpus: prefix-match target for the backend.
final titles = List<String>.generate(150, (j) => 'find ${j * 17} handbook');

/// Query universe: n distinct well-formed queries.
String _query(int k) => 'find $k';

List<String> makeTyped() {
  final rng = Lcg(17);
  return List.generate(n, (i) {
    // ~1 in 10 keys is a lone first character (filtered out downstream).
    if (rng.nextInt(10) == 0) return 'f';
    // ~1 in 4 of the rest lands on the corpus, so the backend keeps returning
    // real matches as the universe grows; the others range over the whole
    // universe and repeat heavily (deduped).
    if (rng.nextDouble() < 0.25) return _query((rng.nextDouble() * 150).floor() * 17);
    return _query(rng.nextInt(n));
  });
}
