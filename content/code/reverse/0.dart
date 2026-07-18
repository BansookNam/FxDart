import 'package:fxdart/fxdart.dart';

void main() {
  print(reverse([1, 2, 3, 4])); // (4, 3, 2, 1)

  final result = fx(['a', 'b', 'c']).reverse().toArray();
  print(result); // [c, b, a]
}
