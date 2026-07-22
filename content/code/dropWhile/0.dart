import 'package:fxdart/fxdart.dart';

void main() {
  // Stops dropping at the first element that fails the test, then yields
  // everything else — even later elements that would have matched:
  print(skipWhile((a) => a < 3, [1, 2, 3, 4, 1, 2])); // (3, 4, 1, 2)
  // FxTS alias: dropWhile((a) => a < 3, [...]) is identical.

  final result = fx([2, 4, 6, 7, 8]).skipWhile((a) => a.isEven).toList();
  print(result); // [7, 8]
}
