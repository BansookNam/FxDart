import 'package:fxdart/fxdart.dart';

void main() {
  final words = ['', 'a', '', 'bcd'];
  final nonEmpty = fx(words).filter(fxNegate(fxIsEmpty)).toList();
  print(nonEmpty); // [a, bcd]
}
