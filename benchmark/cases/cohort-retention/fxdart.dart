import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final users = makeUsers();
  await bench(
    slug: 'cohort-retention',
    impl: 'fxdart',
    n: n,
    run: () {
      final cohorts = fx(users).groupBy((u) => u.signup);
      final rows = fx(cohorts.entries).sortBy((e) => e.key).map((e) {
        final cohort = e.value;
        final cells =
            fx(months).dropWhile((m) => m.compareTo(e.key) <= 0).map((m) {
          final active = fx(cohort).filter((u) => u.active.contains(m)).size();
          return '$m ${(100 * active / cohort.length).round()}%';
        });
        return '${e.key} (${cohort.length} users): ${join(' | ', cells)}';
      });
      return join('\n', ['Cohort retention by signup month', ...rows]);
    },
  );
}
