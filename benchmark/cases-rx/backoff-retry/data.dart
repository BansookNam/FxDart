// Deterministic rate-service ids shared verbatim by both sides. Async-shaped
// headline: 10,000 fetches.
//
// The example fetches ONE rate payload from a service that is unavailable
// exactly twice then serves, budget 3, with 40 ms / 80 ms backoff. Scaled,
// each id gets the example's per-fetch pipeline: ids with id % 7 == 3 (the
// deterministic failure pattern from AUTHORING.md) fail exactly twice then
// serve on the third attempt; every other id serves first try. The chosen
// backoff (40 ms * failures) is still recorded — that is part of the
// example's output — but the wait itself becomes Duration.zero, per
// AUTHORING (delays are zeroed, attempt counts kept).
import '../../harness.dart';

final n = caseN(10000);

final rateIds = List<int>.generate(n, (i) => i + 1);
