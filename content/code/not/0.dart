import 'package:fxdart/fxdart.dart';

void main() {
  print(fxNot(true));  // false
  print(fxNot(false)); // true

  print(fx([true, false, true]).map(fxNot).toList()); // [false, true, false]
}
