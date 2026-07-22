import 'package:fxdart/fxdart.dart';

void main() {
  // Stops at the first element that fails the test, even though a later
  // element (2) would have passed:
  print(takeWhile((a) => a < 5, [1, 2, 3, 7, 2])); // (1, 2, 3)

  final result = fx([2, 4, 6, 7, 8]).takeWhile((a) => a.isEven).toList();
  print(result); // [2, 4, 6]
}
