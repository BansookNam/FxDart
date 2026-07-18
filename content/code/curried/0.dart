import 'package:fxdart/fxdart.dart';

int add2(int a, int b) => a + b;
int add3(int a, int b, int c) => a + b + c;

void main() {
  print(add2.curried(1)(2)); // 3
  print(add3.curried(1)(2)(3)); // 6

  // Partial application: fixing arguments yields new, fully typed functions.
  final addTen = add2.curried(10); // int Function(int)
  print(addTen(5)); // 15
}
