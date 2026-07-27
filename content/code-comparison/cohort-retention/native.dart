import 'package:collection/collection.dart';

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
  print(['Cohort retention by signup month', ...rows].join('\n'));
}
