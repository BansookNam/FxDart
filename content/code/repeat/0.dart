import 'package:fxdart/fxdart.dart';

void main() {
  print(toArray(repeat(3, 'x')));  // [x, x, x]
  print(toArray(repeat(0, 'x')));  // [] — n=0 yields nothing
  print(fx(repeat(4, '-')).join()); // ----
}
