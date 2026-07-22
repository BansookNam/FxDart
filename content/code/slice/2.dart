import 'package:fxdart/fxdart.dart';

void main() {
  final letters = ['a', 'b', 'c', 'd', 'e', 'f'];

  // TODO: use slice to grab the window from index 2 up to (not including) 5
  final window = fx(letters).toList();

  print(window);
}
