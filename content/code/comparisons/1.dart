import 'package:fxdart/fxdart.dart';

bool Function(num) greaterThan(num n) => (b) => gt(b, n);

void main() {
  print(fx([1, 5, 10, 15]).filter(greaterThan(6)).toArray()); // [10, 15]
}
