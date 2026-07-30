// Deterministic log stream shared verbatim by both sides (headline 1M).
import '../../harness.dart';

final n = caseN(1000000);

class Log {
  final String service;
  final String level;
  final String message;
  const Log(this.service, this.level, this.message);
}

const levels = ['ERROR', 'WARN'];

// Service count derives from n (40 at the 1M headline, as before) so each
// service still gets enough alerts that the per-service counts stay distinct
// at small N — verified for this seed at N=100/10,000/1,000,000. The floor is
// 5, not 4: nextInt(4) uses only the Lcg's degenerate low bits (see the
// caution in harness.dart) and collapses every draw to one service. See the
// tie-free note in makeLogs.
final _services =
    List<String>.generate((n ~/ 1000).clamp(5, 40).toInt(), (i) => 'svc-$i');

// 3:4:1:2 ERROR/WARN/INFO/DEBUG mix, like the example's log spread.
const _levelPool = [
  'ERROR', 'ERROR', 'ERROR',
  'WARN', 'WARN', 'WARN', 'WARN',
  'INFO',
  'DEBUG', 'DEBUG',
];

final _messages = List<String>.generate(24, (i) => 'event $i in subsystem');

List<Log> makeLogs() {
  final rng = Lcg(23);
  return List.generate(n, (i) {
    // min-of-two-draws skews traffic towards low service indexes, so the
    // per-service alert counts are all distinct (verified for this seed) —
    // the -count sort must be tie-free because package:collection's sortedBy
    // and fxdart's sortBy order tied entries differently.
    final a = rng.nextInt(_services.length);
    final b = rng.nextInt(_services.length);
    return Log(
      _services[a < b ? a : b],
      _levelPool[rng.nextInt(_levelPool.length)],
      _messages[rng.nextInt(_messages.length)],
    );
  });
}
