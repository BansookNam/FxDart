import 'package:fxdart/fxdart.dart';

void main() {
  print(not(true));  // false
  print(not(false)); // true

  print(fx([true, false, true]).map(not).toList()); // [false, true, false]
}
