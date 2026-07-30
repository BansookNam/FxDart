import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final logs = makeLogs();
  await bench(
    slug: 'recent-errors',
    impl: 'native',
    n: n,
    run: () {
      final seen = <String>{};
      final recent = <Log>[];
      for (final l in logs) {
        if (l.level != 'ERROR') continue;
        if (!seen.add(l.message)) continue;
        recent.add(l);
        if (recent.length == 3) break;
      }
      return recent.map((l) => '${l.time} ${l.message}').join('|');
    },
  );
}
