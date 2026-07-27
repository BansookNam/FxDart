import 'package:fxdart/fxdart.dart';

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

Future<void> main() async {
  final report = await fx(users)
      .filter((u) => u.active)
      .sortBy((u) => u.id)
      .toAsync()
      .map(fetchProfile)
      .concurrent(3)
      .map((p) => '  $p')
      .join('\n');
  print('fetched 10 profiles, 3 at a time:');
  print(report);
  print('max requests in flight: $maxInFlight');
}
