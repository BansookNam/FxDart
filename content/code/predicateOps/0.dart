import 'package:fxdart/fxdart.dart';

bool isEven(int n) => n % 2 == 0;
bool isPositive(int n) => n > 0;

void main() {
  const xs = [-4, -3, 2, 3, 4];

  print(fx(xs).filter(isEven.and(isPositive)).toList()); // [2, 4]
  print(fx(xs).filter(isEven.or(isPositive)).toList()); // [-4, 2, 3, 4]
  print(fx(xs).filter(isEven.xor(isPositive)).toList()); // [-4, 3]
  print(isEven.negate(3)); // true
}
