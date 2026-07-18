import 'package:fxdart/fxdart.dart';

void main() {
  print(includes(3, [1, 2, 3])); // true
  print(includes(9, [1, 2, 3])); // false

  // Chain form is Iterable's own .contains — same semantics:
  print(fx(['a', 'b', 'c']).contains('b')); // true
}
