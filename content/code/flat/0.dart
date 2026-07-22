import 'package:fxdart/fxdart.dart';

void main() {
  // Data-first form. Returns Iterable<dynamic> -- Dart has no type for
  // "however deep this nesting goes", so the depth is decided at runtime.
  print(toList(flattened([1, [2, 3], [4, [5]]])));   // [1, 2, 3, 4, [5]]
  print(toList(flattened([1, [2, [3]]], 2)));        // [1, 2, 3]
  // FxTS alias: flat([1, [2, 3]]) is identical.

  // Chain form:
  final chained = fx([1, 2, [3, 4]]).flattened().toList();
  print(chained); // [1, 2, 3, 4]
}
