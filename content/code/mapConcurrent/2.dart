import 'package:fxdart/fxdart.dart';

Future<String> fetchUser(int id) async {
  await Future.delayed(const Duration(milliseconds: 10));
  return 'user#$id';
}

void main() async {
  final ids = [11, 12, 13, 14];

  // TODO: fetch every user, two at a time, keeping source order —
  // one mapConcurrent call instead of toAsync().map(...).concurrent(2).
  final users = await fx(ids).toAsync().map(fetchUser).toList();

  print(users); // should print: [user#11, user#12, user#13, user#14]
}
