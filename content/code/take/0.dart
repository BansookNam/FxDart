import 'package:fxdart/fxdart.dart';

void main() {
  // Data-first form:
  print(take(3, [1, 2, 3, 4, 5])); // (1, 2, 3)

  // take on an infinite source: cycle() repeats forever, take(7) still stops.
  final result = fx(cycle([1, 2, 3])).take(7).toList();
  print(result); // [1, 2, 3, 1, 2, 3, 1]
}
