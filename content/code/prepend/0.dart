import 'package:fxdart/fxdart.dart';

void main() {
  print(prepend(0, [1, 2, 3])); // (0, 1, 2, 3)

  final result = fx(['b', 'c']).prepend('a').toArray();
  print(result); // [a, b, c]
}
