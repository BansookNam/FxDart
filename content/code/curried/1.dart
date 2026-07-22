import 'package:fxdart/fxdart.dart';

int multiply(int a, int b) => a * b;
String echoTimes(String s, int times) => s * times;

void main() {
  print(fx([1, 2, 3]).map(multiply.curried(10)).toList()); // [10, 20, 30]

  print(fx([1, 2, 3]).map(echoTimes.curried('na')).toList());
  // [na, nana, nanana]
}
