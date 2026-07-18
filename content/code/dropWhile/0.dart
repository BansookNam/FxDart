import 'package:fxdart/fxdart.dart';

void main() {
  // Stops dropping at the first element that fails the test, then yields
  // everything else — even later elements that would have matched:
  print(dropWhile((a) => a < 3, [1, 2, 3, 4, 1, 2])); // (3, 4, 1, 2)

  final result = fx([2, 4, 6, 7, 8]).dropWhile((a) => a.isEven).toArray();
  print(result); // [7, 8]
}
