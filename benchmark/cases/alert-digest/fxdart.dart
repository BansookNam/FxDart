import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final logs = makeLogs();
  await bench(
    slug: 'alert-digest',
    impl: 'fxdart',
    n: n,
    run: () {
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
              ])
          .toList();

      return 'ERROR ${byLevel['ERROR']}, WARN ${byLevel['WARN']}|'
          '${body.length}|${body.first}|${body.last}';
    },
  );
}
