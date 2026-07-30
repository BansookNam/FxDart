import 'package:collection/collection.dart';

import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final users = makeUsers();
  await bench(
    slug: 'cohort-retention',
    impl: 'native',
    n: n,
    run: () {
      final cohorts = users.groupListsBy((u) => u.signup);
      final rows = <String>[];
      for (final key in cohorts.keys.sorted()) {
        final cohort = cohorts[key]!;
        final cells = <String>[];
        for (final m in months.skipWhile((m) => m.compareTo(key) <= 0)) {
          final active = cohort.where((u) => u.active.contains(m)).length;
          cells.add('$m ${(100 * active / cohort.length).round()}%');
        }
        rows.add('$key (${cohort.length} users): ${cells.join(' | ')}');
      }
      return ['Cohort retention by signup month', ...rows].join('\n');
    },
  );
}
