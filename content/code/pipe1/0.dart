import 'package:fxdart/fxdart.dart';

void main() {
  // With a plain (non-Future) value, pipe1 just calls f(a) directly.
  final result = pipe1(21, (int a) => a * 2);
  print(result); // 42
  print(result.runtimeType); // int
}
