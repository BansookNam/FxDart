import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  // When `a` is a Future, pipe1 awaits it before calling f — so f itself
  // never has to know whether it's chained after sync or async work.
  final pending = delay(const Duration(milliseconds: 100), 10);

  final result = await pipe1(pending, (int a) => a + 5);
  print(result); // 15

  // Chaining pipe1 calls composes async steps one at a time.
  final chained = await pipe1(
      pipe1(delay(const Duration(milliseconds: 50), 2), (int a) => a * 3),
      (int a) => a + 1);
  print(chained); // 7
}
