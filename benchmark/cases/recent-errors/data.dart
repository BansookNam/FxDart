// Deterministic n-line log, newest first, shared verbatim by both sides
// (headline 1,000,000; the runner also runs N=100 and N=10,000 via BENCH_N).
// The pipeline stops after 3 DISTINCT error messages, so to keep the scaled
// case from short-circuiting after a handful of lines the data only contains
// two distinct error messages until near the end of the list: the third
// distinct message appears once, min(1000, n/10) lines before the end (1000
// at the headline N, scaled down so the position stays valid at N=100). Both
// sides therefore traverse ~n lines before `take(3)` completes — same shape
// as the example, scaled.
import '../../harness.dart';

final n = caseN(1000000);

class Log {
  final String time;
  final String level;
  final String message;
  const Log(this.time, this.level, this.message);
}

const _commonErrors = ['payment gateway timeout', 'inventory service 503'];
const _rareError = 'disk quota exceeded';
final _rareErrorIndex = n - (n ~/ 10).clamp(1, 1000);

const _infoMessages = [
  'checkout started',
  'cache warmed',
  'server started',
  'retrying request',
];

List<Log> makeLogs() {
  final rng = Lcg(2);
  return List.generate(n, (i) {
    final minutes = (n - 1 - i) % 1440;
    final time =
        '${(minutes ~/ 60).toString().padLeft(2, '0')}:'
        '${(minutes % 60).toString().padLeft(2, '0')}';
    if (i == _rareErrorIndex) return Log(time, 'ERROR', _rareError);
    final level = ['INFO', 'WARN', 'ERROR'][rng.nextInt(3)];
    // nextDouble (high bits), not nextInt(2): the LCG's low bit alternates
    // with period 2, which would make one common error message unreachable.
    final message = level == 'ERROR'
        ? _commonErrors[rng.nextDouble() < 0.5 ? 0 : 1]
        : _infoMessages[rng.nextInt(_infoMessages.length)];
    return Log(time, level, message);
  });
}
