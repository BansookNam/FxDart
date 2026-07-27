class Log {
  final String time;
  final String level;
  final String message;
  const Log(this.time, this.level, this.message);
}

// Newest first, as a log store would return them.
const logs = [
  Log('09:41', 'ERROR', 'payment gateway timeout'),
  Log('09:40', 'INFO', 'checkout started'),
  Log('09:38', 'ERROR', 'payment gateway timeout'),
  Log('09:35', 'WARN', 'retrying request'),
  Log('09:31', 'ERROR', 'inventory service 503'),
  Log('09:28', 'INFO', 'cache warmed'),
  Log('09:22', 'ERROR', 'payment gateway timeout'),
  Log('09:17', 'ERROR', 'invalid session token'),
  Log('09:12', 'ERROR', 'disk quota exceeded'),
  Log('09:05', 'INFO', 'server started'),
];

void main() {
  final seen = <String>{};
  final recent = <Log>[];
  for (final l in logs) {
    if (l.level != 'ERROR') continue;
    if (!seen.add(l.message)) continue;
    recent.add(l);
    if (recent.length == 3) break;
  }
  for (final l in recent) {
    print('${l.time} ${l.message}');
  }
}
