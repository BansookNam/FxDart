import 'package:fxdart/fxdart.dart';

void main() {
  // Data-first form. Returns Iterable<dynamic> -- Dart has no type for
  // "however deep this nesting goes", so the depth is decided at runtime.
  print(toArray(flat([1, [2, 3], [4, [5]]])));       // [1, 2, 3, 4, [5]]
  print(toArray(flat([1, [2, [3]]], 2)));             // [1, 2, 3]

  // Chain form:
  final chained = fx([1, 2, [3, 4]]).flat().toArray();
  print(chained); // [1, 2, 3, 4]
}
