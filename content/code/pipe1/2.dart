import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  // TODO: use pipe1 to turn a delayed name into a greeting.
  final greeting = await pipe1(
      delay(const Duration(milliseconds: 80), 'kim'),
      (String name) => 'hello, $name!');

  print(greeting); // hello, kim!
}
