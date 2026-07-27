import 'package:fxdart/fxdart.dart';

class User {
  final String name;
  final String signup; // signup month, 'yyyy-mm'
  final List<String> active; // months with at least one session
  const User(this.name, this.signup, this.active);
}

const months = ['2026-04', '2026-05', '2026-06', '2026-07'];

const users = [
  User('ana', '2026-04', ['2026-04', '2026-05', '2026-06', '2026-07']),
  User('ben', '2026-04', ['2026-04', '2026-05']),
  User('cleo', '2026-04', ['2026-04', '2026-06']),
  User('dan', '2026-04', ['2026-04']),
  User('eve', '2026-05', ['2026-05', '2026-06', '2026-07']),
  User('finn', '2026-05', ['2026-05', '2026-07']),
  User('gus', '2026-05', ['2026-05']),
  User('hana', '2026-06', ['2026-06', '2026-07']),
  User('ivan', '2026-06', ['2026-06']),
];

void main() {
  final cohorts = fx(users).groupBy((u) => u.signup);
  final rows = fx(cohorts.entries).sortBy((e) => e.key).map((e) {
    final cohort = e.value;
    final cells = fx(months).dropWhile((m) => m.compareTo(e.key) <= 0).map((m) {
      final active = fx(cohort).filter((u) => u.active.contains(m)).size();
      return '$m ${(100 * active / cohort.length).round()}%';
    });
    return '${e.key} (${cohort.length} users): ${join(' | ', cells)}';
  });
  print(join('\n', ['Cohort retention by signup month', ...rows]));
}
