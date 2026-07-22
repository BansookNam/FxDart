import 'package:fxdart/fxdart.dart';

void main() {
  print(takeLast(3, [1, 2, 3, 4, 5, 6])); // (4, 5, 6)
  // FxTS alias: takeRight(3, [1, 2, 3, 4, 5, 6]) is identical.

  // Chain form:
  final result = fx([10, 20, 30, 40]).takeLast(2).toList();
  print(result); // [30, 40]
}
