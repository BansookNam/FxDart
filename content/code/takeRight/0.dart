import 'package:fxdart/fxdart.dart';

void main() {
  print(takeRight(3, [1, 2, 3, 4, 5, 6])); // (4, 5, 6)

  // Chain form:
  final result = fx([10, 20, 30, 40]).takeRight(2).toArray();
  print(result); // [30, 40]
}
