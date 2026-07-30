import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final logs = makeLogs();
  await bench(
    slug: 'top-log-level',
    impl: 'fxdart',
    n: n,
    run: () {
      // countBy is terminal (returns a Map) — re-enter the chain on entries.
      final counts = fx(logs).countBy((l) => l.level);
      final top = fx(counts.entries).maxBy((e) => e.value)!;
      return '${top.key}|${top.value}|${logs.length}';
    },
  );
}
