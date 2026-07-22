import 'package:fxdart/fxdart.dart';

void main() {
  final result = fx([1, 2, 3, 4, 5])
      .map((a) => a + 10)
      .filter((a) => a % 2 == 0)
      .toList();

  print(result); // [12, 14]
}
