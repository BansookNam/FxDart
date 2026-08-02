// Async case (#35 ordered-bounded-fetch): n profile fetches, at most 4 in
// flight, results in source order. Headline 10,000 — the RxDartComparison
// async family's headline scale; fetches are Duration.zero, so the
// flatMap(maxConcurrent: 4)+tag+sort vs mapConcurrent(4) machinery is what
// is measured, with the observed in-flight peak folded into the checksum.
import '../../harness.dart';

final n = caseN(10000);

final userIds = List<int>.generate(n, (i) => i + 1);
