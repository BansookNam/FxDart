import 'package:fxdart/fxdart.dart';

void main() {
  print(fxZipWith((a, b) => '$a$b', ['x', 'y', 'z'], [1, 2, 3]));
  // (x1, y2, z3)

  final result = fxZipWith((a, b) => a + b, [1, 2, 3], [10, 20, 30]);
  print(fxToList(result)); // [11, 22, 33]
}
