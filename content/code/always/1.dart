import 'package:fxdart/fxdart.dart';

void main() {
  final classify = fxCases<int, String>([
    ((n) => n < 0, (n) => 'negative'),
    ((n) => n == 0, (n) => 'zero'),
  ], orElse: fxAlways('positive'));

  print(fx([-2, 0, 7]).map(classify).toList()); // [negative, zero, positive]
}
