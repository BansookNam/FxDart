import 'package:fxdart/fxdart.dart';

void main() {
  final words = ['', 'a', '', 'bcd'];
  final nonEmpty = fx(words).filter(negate(isEmpty)).toArray();
  print(nonEmpty); // [a, bcd]
}
