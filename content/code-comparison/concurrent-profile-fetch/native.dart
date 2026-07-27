import 'package:collection/collection.dart';

class User {
  final int id;
  final String name;
  final bool active;
  const User(this.id, this.name, this.active);
}

const users = [
  User(4, 'Dana', true), User(1, 'Ada', true), User(9, 'Ines', true),
  User(3, 'Chidi', false), User(7, 'Gus', true), User(2, 'Bram', true),
  User(11, 'Kira', true), User(6, 'Fay', true), User(8, 'Hana', false),
  User(12, 'Liam', true), User(5, 'Eli', true), User(10, 'Jun', true),
];

int inFlight = 0;
int maxInFlight = 0;

Future<String> fetchProfile(User u) async {
  inFlight++;
  if (inFlight > maxInFlight) maxInFlight = inFlight;
  await Future.delayed(Duration(milliseconds: 10 + u.id % 3 * 5));
  inFlight--;
  return 'user#${u.id} ${u.name} <${u.name.toLowerCase()}@example.com>';
}

/// A hand-rolled worker pool: [limit] workers pull from a shared cursor,
/// writing into pre-sized slots so the output keeps the input order.
Future<List<String>> fetchAll(List<User> targets, int limit) async {
  final results = List<String?>.filled(targets.length, null);
  var next = 0;
  Future<void> worker() async {
    while (next < targets.length) {
      final i = next++;
      results[i] = await fetchProfile(targets[i]);
    }
  }

  await Future.wait([for (var i = 0; i < limit; i++) worker()]);
  return results.cast<String>();
}

Future<void> main() async {
  final targets = users.where((u) => u.active).sortedBy<num>((u) => u.id);
  final profiles = await fetchAll(targets, 3);
  print('fetched 10 profiles, 3 at a time:');
  print(profiles.map((p) => '  $p').join('\n'));
  print('max requests in flight: $maxInFlight');
}
