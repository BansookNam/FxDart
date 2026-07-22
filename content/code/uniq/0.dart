import 'package:fxdart/fxdart.dart';

void main() {
  // Data-first form:
  print(toList(distinct([1, 2, 2, 3, 1, 4]))); // [1, 2, 3, 4]
  // FxTS alias: uniq([1, 2, 2, 3, 1, 4]) does the same thing.

  // Chain form:
  final result = fx(['a', 'b', 'a', 'c', 'b']).distinct().toList();
  print(result); // [a, b, c]
}
