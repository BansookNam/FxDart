import 'package:fxdart/fxdart.dart';

void main() {
  print(isNil(null)); // true — no distinction from isNull in Dart
  // ignore: deprecated_member_use
  print(isUndefined(null)); // true — deprecated alias of isNull
  // ignore: deprecated_member_use
  print(isArray([1, 2])); // true — deprecated alias of isList
  // ignore: deprecated_member_use
  print(isObject({'a': 1})); // true — deprecated alias of isMap
}
