import 'package:fxdart/fxdart.dart';

void main() {
  print(not(true));  // false
  print(not(false)); // true

  print(fx([true, false, true]).map(not).toArray()); // [false, true, false]
}
