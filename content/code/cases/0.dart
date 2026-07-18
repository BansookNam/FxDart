import 'package:fxdart/fxdart.dart';

void main() {
  final classify = cases<int, String>([
    ((n) => n < 0, (n) => 'negative'),
    ((n) => n == 0, (n) => 'zero'),
  ], orElse: (n) => 'positive');

  print(classify(-4)); // negative
  print(classify(0));  // zero
  print(classify(9));  // positive
}
