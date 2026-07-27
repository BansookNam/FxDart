import 'package:fxdart/fxdart.dart';

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
  final alerts = fx(logs).filter((l) => levels.contains(l.level)).toList();
  final byLevel = fx(alerts).countBy((l) => l.level);

  final body = fx(fx(alerts).groupBy((l) => l.service).entries)
      .sortBy((e) => -e.value.length)
      .flatMap((e) => [
            '${e.key} (${e.value.length})',
            ...fx(levels).flatMap((lvl) {
              final msgs =
                  fx(e.value).filter((l) => l.level == lvl).toList();
              if (msgs.isEmpty) return const <String>[];
              return [
                '  $lvl x${msgs.length}',
                ...fx(msgs).map((l) => '    - ${l.message}').uniq(),
              ];
            }),
          ]);

  print(join('\n', [
    'Alert digest — ERROR ${byLevel['ERROR']}, WARN ${byLevel['WARN']}',
    ...body,
  ]));
}
