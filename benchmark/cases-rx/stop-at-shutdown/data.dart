// Deterministic event feed shared verbatim by both sides.
//
// The example's SHUTDOWN marker sits at position 7 of 9; scaled, it sits at
// 90% depth — n-derived, per the early-exit rule — so the inclusive take
// does n-proportional work while the last 10% are next-run stragglers that
// must be dropped.
import '../../harness.dart';

final n = caseN(1000000);

final shutdownAt = n * 9 ~/ 10;

const _kinds = [
  'boot',
  'listen :8080',
  'GET /orders',
  'GET /health',
  'SIGTERM',
  'drain connections',
];

List<String> makeEvents() => List.generate(
    n, (i) => i == shutdownAt ? 'SHUTDOWN' : '${_kinds[i % _kinds.length]} #$i');
