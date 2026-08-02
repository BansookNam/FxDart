// Deterministic manifest ids shared verbatim by both sides. Async-shaped
// headline: 10,000 fetches.
//
// The example fetches ONE manifest whose endpoint resets exactly twice then
// serves, budget 3. Scaled, each id gets the example's per-fetch pipeline:
// endpoints with id % 7 == 3 (the deterministic failure pattern from
// AUTHORING.md) reset exactly twice then serve on the third attempt —
// spending the whole budget, like the example — and every other id serves
// on the first attempt.
import '../../harness.dart';

final n = caseN(10000);

final manifestIds = List<int>.generate(n, (i) => i + 1);
