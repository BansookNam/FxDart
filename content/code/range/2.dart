import 'package:fxdart/fxdart.dart';

void main() {
  // TODO: use range to build the even numbers from 2 to 10 inclusive.
  final evens = fx(range(2, 11, 2)).toList();

  print(evens); // [2, 4, 6, 8, 10]
}
