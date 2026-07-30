import 'package:collection/collection.dart';

import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final logs = makeLogs();
  await bench(
    slug: 'top-log-level',
    impl: 'native',
    n: n,
    run: () {
      // No countBy: group the whole entries into lists, then keep the lengths.
      final counts = logs
          .groupListsBy((l) => l.level)
          .map((level, entries) => MapEntry(level, entries.length));
      // No maxBy on entries either: reduce with an explicit comparison.
      final top = counts.entries.reduce((a, b) => b.value > a.value ? b : a);
      return '${top.key}|${top.value}|${logs.length}';
    },
  );
}
