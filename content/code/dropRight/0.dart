import 'package:fxdart/fxdart.dart';

void main() {
  print(dropRight(2, [1, 2, 3, 4, 5])); // (1, 2, 3)

  final result = fx([10, 20, 30, 40]).dropRight(1).toArray();
  print(result); // [10, 20, 30]
}
