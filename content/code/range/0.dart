import 'package:fxdart/fxdart.dart';

void main() {
  print(fxToList(fxRange(4)));        // [0, 1, 2, 3] — one arg counts 0..start
  print(fxToList(fxRange(1, 4)));     // [1, 2, 3]
  print(fxToList(fxRange(4, 1, -1))); // [4, 3, 2] — negative step counts down
  print(fxToList(fxRange(0, 10, 3))); // [0, 3, 6, 9]
}
