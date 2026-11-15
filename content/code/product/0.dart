import 'package:fxdart/fxdart.dart';

void main() {
  print(fxProduct([2, 3, 4])); // 24
  print(fxProduct(<num>[])); // 1  (the multiplicative identity)

  // All ints stay an int; the first double switches to double:
  print(fxProduct([2, 3]) is int); // true
  print(fxProduct([2, 0.5, 3])); // 3.0

  // Empty is 1 so that splitting the input never changes the answer:
  final a = [2, 5];
  final b = <int>[];
  print(fxProduct([...a, ...b]) == fxProduct(a) * fxProduct(b)); // true

  // The chain spelling, on an Fx of numbers:
  print(fx([1, 2, 3, 4, 5]).product()); // 120
}
