// Async case: 1M real awaits is infeasible, so the async cases measure the
// pipeline machinery over a large-but-finishable N with zero-length delays.
import '../../harness.dart';

final n = caseN(5000);

class User {
  final int id;
  final String name;
  final bool active;
  const User(this.id, this.name, this.active);
}

const _names = [
  'Ada', 'Bram', 'Chidi', 'Dana', 'Eli', 'Fay',
  'Gus', 'Hana', 'Ines', 'Jun', 'Kira', 'Liam',
];

// Ids are a shuffled bijection on [1, n] (like the example's unsorted user
// list), so the id sort has real work and no ties. id % 5 == 0 -> inactive.
final users = List<User>.generate(n, (i) {
  final id = ((i * 2654435761) % n) + 1;
  return User(id, '${_names[id % _names.length]}$id', id % 5 != 0);
});
