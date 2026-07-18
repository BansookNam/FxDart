import 'package:fxdart/fxdart.dart';

void main() {
  print(isEmpty(null));       // true
  print(isEmpty(''));         // true
  print(isEmpty([]));         // true
  print(isEmpty({}));         // true
  print(isEmpty([1, 2]));     // false
  print(isEmpty(0));          // false — numbers are never "empty"
  print(isEmpty(false));      // false
}
