import 'package:collection/collection.dart';

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
  // No countBy: group the whole entries into lists, then keep the lengths.
  final counts = logs
      .groupListsBy((l) => l.level)
      .map((level, entries) => MapEntry(level, entries.length));
  // No maxBy on entries either: reduce with an explicit comparison.
  final top = counts.entries.reduce((a, b) => b.value > a.value ? b : a);
  print('Most frequent level: ${top.key} (${top.value} of ${logs.length})');
}
