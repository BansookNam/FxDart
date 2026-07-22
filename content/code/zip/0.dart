import 'package:fxdart/fxdart.dart';

void main() {
  // TS tuples become Dart records:
  print(zip(['a', 'b', 'c'], [1, 2, 3])); // ((a, 1), (b, 2), (c, 3))

  // Stops as soon as the shorter iterable runs out:
  print(zip(['a', 'b'], [1, 2, 3, 4])); // ((a, 1), (b, 2))

  // Three-way variant:
  print(zip3(['a', 'b'], [1, 2], [true, false])); // ((a, 1, true), (b, 2, false))

  final result = fx(['x', 'y']).zip([10, 20]).toList();
  print(result); // [(x, 10), (y, 20)]
}
