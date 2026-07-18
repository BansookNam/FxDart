import 'package:fxdart/fxdart.dart';

void main() {
  print(drop(2, [1, 2, 3, 4, 5])); // (3, 4, 5)

  // Chain form (also aliased as .skip, matching Iterable):
  final result = fx([1, 2, 3, 4, 5]).drop(2).toArray();
  print(result); // [3, 4, 5]
}
