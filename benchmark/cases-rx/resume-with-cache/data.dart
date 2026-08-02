// Deterministic live feed + cached snapshot shared verbatim by both sides.
// Async-shaped headline: 10,000 dashboard rows.
//
// The example's feed dies after 3 of the 6 rows the dashboard shows, with a
// 4-row cache of which one row goes unused. Scaled with the same ratios,
// all n-derived: the source error lands at half the take depth, and the
// cached tail (2n/3) is longer than the n/2 rows actually pulled from it.
import '../../harness.dart';

final n = caseN(10000);

final liveCount = n ~/ 2;
final cachedCount = n * 2 ~/ 3;
final takeCount = n;

const _statuses = ['packed', 'shipped', 'picking', 'received'];

String _update(int i) => 'ORD-${7011 + i} ${_statuses[i % _statuses.length]}';

List<String> makeLiveUpdates() => List.generate(liveCount, _update);

List<String> makeCachedTail() =>
    List.generate(cachedCount, (i) => _update(liveCount + i));
