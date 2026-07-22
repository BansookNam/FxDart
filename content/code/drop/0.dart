import 'package:fxdart/fxdart.dart';

void main() {
  print(skip(2, [1, 2, 3, 4, 5])); // (3, 4, 5)
  // FxTS alias: drop(2, [1, 2, 3, 4, 5]) is identical.

  // Chain form (matches Iterable.skip):
  final result = fx([1, 2, 3, 4, 5]).skip(2).toList();
  print(result); // [3, 4, 5]
}
