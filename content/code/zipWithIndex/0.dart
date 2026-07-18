import 'package:fxdart/fxdart.dart';

void main() {
  print(zipWithIndex(['a', 'b', 'c'])); // ((0, a), (1, b), (2, c))

  final result = fx(['x', 'y', 'z']).zipWithIndex().toArray();
  print(result); // [(0, x), (1, y), (2, z)]
}
