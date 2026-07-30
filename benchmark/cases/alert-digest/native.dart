import 'package:collection/collection.dart';

import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final logs = makeLogs();
  await bench(
    slug: 'alert-digest',
    impl: 'native',
    n: n,
    run: () {
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

      return 'ERROR ${byLevel['ERROR']}, WARN ${byLevel['WARN']}|'
          '${body.length}|${body.first}|${body.last}';
    },
  );
}
