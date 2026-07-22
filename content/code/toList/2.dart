import 'package:fxdart/fxdart.dart';

void main() {
  // TODO: materialize the first 4 squares of range(100) into a List.
  final squares = fx(range(100)).map((a) => a * a).take(4).toList();

  print(squares); // [0, 1, 4, 9]
}
