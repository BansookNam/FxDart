import 'package:fxdart/fxdart.dart';

void main() {
  print(fxIsEmpty(null));       // true
  print(fxIsEmpty(''));         // true
  print(fxIsEmpty([]));         // true
  print(fxIsEmpty({}));         // true
  print(fxIsEmpty([1, 2]));     // false
  print(fxIsEmpty(0));          // false — numbers are never "empty"
  print(fxIsEmpty(false));      // false
}
