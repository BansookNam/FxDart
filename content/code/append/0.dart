import 'package:fxdart/fxdart.dart';

void main() {
  print(append(4, [1, 2, 3])); // (1, 2, 3, 4)

  final result = fx(['a', 'b']).append('c').toList();
  print(result); // [a, b, c]
}
