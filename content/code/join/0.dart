import 'package:fxdart/fxdart.dart';

void main() {
  // Data-first form: separator comes FIRST, unlike Dart's Iterable.join.
  print(join(', ', ['a', 'b', 'c'])); // a, b, c

  // Chain form reuses Dart's built-in Iterable.join(separator), whose
  // default separator is '' (empty), not ',':
  print(fx([1, 2, 3]).join('-')); // 1-2-3
  print(fx([1, 2, 3]).join()); // 123
}
