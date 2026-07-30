// Deterministic paged log stores shared verbatim by both sides
// (headline 8,000 events across the two stores).
// Async case: page-fetch delay is Duration.zero.
//
// Scaled shape of the example: two stores paged 3 events per call; the
// replica overlaps the primary (its first n/8 events were also shipped to
// the primary), and the pipeline stops after the first `takeN` unique events
// — well before the replica is fully paged, so the early-exit behaviour
// ("pages fetched: X of Y") stays load-bearing.
//
// The example's fixed numbers (4000/3000/4000, take 5000) are fractions of
// the 8000 headline; they are derived from n so the overlap and the
// mid-stream early exit hold at every BENCH_N scale:
//   primary holds ids 0 .. n/2-1, replica ids 3n/8 .. 7n/8-1 (n/8 overlap),
//   unique total 7n/8, takeN = 5n/8 < 7n/8 — take always stops mid-stream.
import '../../harness.dart';

final _base = caseN(8000);
final primaryCount = _base ~/ 2; // event ids 0 .. primaryCount-1
final replicaStart = _base * 3 ~/ 8; // overlap of _base/8 with the primary
final replicaCount = _base ~/ 2;
const pageSize = 3;
final takeN = _base * 5 ~/ 8; // first takeN unique events

/// Total events held across both stores (dataset size echoed by the harness).
final n = primaryCount + replicaCount;

class Event {
  final String id;
  final String msg;
  const Event(this.id, this.msg);
}

Event _event(int i) => Event('e$i', 'log line ${i % 97}');

List<List<Event>> _paged(int start, int count) => [
      for (var p = 0; p * pageSize < count; p++)
        [
          for (var i = p * pageSize;
              i < count && i < (p + 1) * pageSize;
              i++)
            _event(start + i)
        ]
    ];

List<List<Event>> makePrimary() => _paged(0, primaryCount);
List<List<Event>> makeReplica() => _paged(replicaStart, replicaCount);
