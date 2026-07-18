import 'package:fxdart/fxdart.dart';

void main() {
  final values = <Object?>[null, '', 'hi', [], [1], 0];

  // isEmpty is a plain unary function, so it tears off straight into filter:
  final empties = filter(isEmpty, values);
  print(empties.toList()); // [null, , []]
}
