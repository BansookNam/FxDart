import 'package:fxdart/fxdart.dart';

bool isEven(int n) => n % 2 == 0;

void main() {
  final isOdd = negate(isEven);
  print(isOdd(3)); // true
  print(isOdd(4)); // false

  print(fx([1, 2, 3, 4, 5]).filter(negate(isEven)).toArray()); // [1, 3, 5]
}
