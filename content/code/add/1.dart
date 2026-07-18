import 'package:fxdart/fxdart.dart';

void main() {
  // add as a reducer
  print(fx([1, 2, 3, 4]).reduce(add)); // 10

  // add closed over for use as a unary map callback
  int Function(int) plus(int n) => (b) => add(n, b);
  print(fx([1, 2, 3]).map(plus(10)).toArray()); // [11, 12, 13]
}
