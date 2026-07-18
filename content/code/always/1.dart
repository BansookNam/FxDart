import 'package:fxdart/fxdart.dart';

void main() {
  final classify = cases<int, String>([
    ((n) => n < 0, (n) => 'negative'),
    ((n) => n == 0, (n) => 'zero'),
  ], orElse: always('positive'));

  print(fx([-2, 0, 7]).map(classify).toArray()); // [negative, zero, positive]
}
