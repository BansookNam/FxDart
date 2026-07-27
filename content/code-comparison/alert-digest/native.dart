import 'package:collection/collection.dart';

class Log {
  final String service;
  final String level;
  final String message;
  const Log(this.service, this.level, this.message);
}

const logs = [
  Log('api', 'ERROR', 'timeout calling billing'),
  Log('api', 'WARN', 'slow query 1.2s'),
  Log('api', 'ERROR', 'timeout calling billing'),
  Log('auth', 'WARN', 'token near expiry'),
  Log('api', 'INFO', 'deploy finished'),
  Log('billing', 'ERROR', 'invoice 442 failed'),
  Log('auth', 'ERROR', 'bad signature'),
  Log('billing', 'WARN', 'retrying charge'),
  Log('auth', 'WARN', 'token near expiry'),
  Log('api', 'WARN', 'disk 85% full'),
  Log('api', 'DEBUG', 'cache warm'),
];

const levels = ['ERROR', 'WARN'];

void main() {
  final alerts = logs.where((l) => levels.contains(l.level)).toList();
  final byLevel = <String, int>{};
  for (final l in alerts) {
    byLevel[l.level] = (byLevel[l.level] ?? 0) + 1;
  }

  final services = alerts.groupListsBy((l) => l.service);
  final body = <String>[];
  for (final e in services.entries.sortedBy<num>((e) => -e.value.length)) {
    body.add('${e.key} (${e.value.length})');
    for (final lvl in levels) {
      final msgs = e.value.where((l) => l.level == lvl).toList();
      if (msgs.isEmpty) continue;
      body.add('  $lvl x${msgs.length}');
      final seen = <String>{};
      for (final l in msgs) {
        if (seen.add(l.message)) body.add('    - ${l.message}');
      }
    }
  }

  print([
    'Alert digest — ERROR ${byLevel['ERROR']}, WARN ${byLevel['WARN']}',
    ...body,
  ].join('\n'));
}
