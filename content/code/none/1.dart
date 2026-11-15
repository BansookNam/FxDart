import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  final scores = [3, 9, 4, 10, 8];

  // Three spellings of the same question:
  print(fx(scores).none((s) => s > 10)); // true
  print(!fx(scores).some((s) => s > 10)); // true
  print(fx(scores).atMost(0, (s) => s > 10)); // true

  // ...and its link to every: none(f) is every(not f).
  print(fx(scores).every((s) => s <= 10)); // true

  // Async: the predicate may await; upstream is cancelled
  // at the first match.
  Future<bool> isBanned(String user) async => user == 'mallory';
  final users = fxToAsync(['alice', 'bob', 'mallory', 'carol']);
  print(await fxAsync(users).none(isBanned)); // false
}
