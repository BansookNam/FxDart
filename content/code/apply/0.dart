import 'package:fxdart/fxdart.dart';

int add3(int a, int b, int c) => a + b + c;

void main() {
  print(fxApply<int>(add3, [1, 2, 3])); // 6

  // deprecated curry stub — prefer a closure like (b) => f(a, b)
  // ignore: deprecated_member_use
  final addCurried = fxCurry((int a, int b) => a + b);
  print(addCurried(2)(3)); // 5
}
