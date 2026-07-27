import 'package:fxdart/fxdart.dart';

class LogEntry {
  final String level;
  final String message;
  const LogEntry(this.level, this.message);
}

const logs = [
  LogEntry('INFO', 'server started'),
  LogEntry('WARN', 'disk 80% full'),
  LogEntry('INFO', 'user login'),
  LogEntry('ERROR', 'payment timeout'),
  LogEntry('WARN', 'slow query 1.2s'),
  LogEntry('WARN', 'retrying webhook'),
  LogEntry('INFO', 'cache warmed'),
  LogEntry('WARN', 'disk 85% full'),
  LogEntry('ERROR', 'payment timeout'),
];

void main() {
  // countBy is terminal (returns a Map) — re-enter the chain on entries.
  final counts = fx(logs).countBy((l) => l.level);
  final top = fx(counts.entries).maxBy((e) => e.value)!;
  print('Most frequent level: ${top.key} (${top.value} of ${logs.length})');
}
