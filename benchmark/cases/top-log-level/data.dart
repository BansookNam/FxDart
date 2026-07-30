// Deterministic 1,000,000-entry log shared verbatim by both sides.
// The level distribution is skewed (INFO ~45%) so the most frequent level
// is unambiguous — reduce/maxBy tie-breaking can never differ between sides.
import '../../harness.dart';

final n = caseN(1000000);

class LogEntry {
  final String level;
  final String message;
  const LogEntry(this.level, this.message);
}

const _messages = [
  'server started', 'disk 80% full', 'user login', 'payment timeout',
  'slow query 1.2s', 'retrying webhook', 'cache warmed', 'disk 85% full',
];

List<LogEntry> makeLogs() {
  final rng = Lcg(7);
  return List.generate(n, (i) {
    final r = rng.nextInt(100);
    final level = r < 45
        ? 'INFO'
        : r < 75
            ? 'WARN'
            : r < 90
                ? 'DEBUG'
                : 'ERROR';
    return LogEntry(level, _messages[rng.nextInt(_messages.length)]);
  });
}
