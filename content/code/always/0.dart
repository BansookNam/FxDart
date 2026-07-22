import 'package:fxdart/fxdart.dart';

void main() {
  final greet = always('hi');
  print(greet());    // hi
  print(greet(123)); // hi (ignores the argument)

  // realistic: reset every element of a list to a fixed value
  print(fx([1, 2, 3]).map(always(0)).toList()); // [0, 0, 0]
}
