import 'package:fxdart/fxdart.dart';

void main() {
  // Data-first form:
  print(toArray(uniq([1, 2, 2, 3, 1, 4]))); // [1, 2, 3, 4]

  // Chain form:
  final result = fx(['a', 'b', 'a', 'c', 'b']).uniq().toArray();
  print(result); // [a, b, c]
}
