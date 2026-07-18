import 'package:fxdart/fxdart.dart';

void main() {
  final letters = ['a', 'b', 'c', 'd'];
  print(nth(0, letters));  // a
  print(nth(2, letters));  // c
  print(nth(10, letters)); // null
  print(nth(-1, letters)); // null (negative indices are simply out of range)
}
