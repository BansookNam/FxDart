import 'package:fxdart/fxdart.dart';

void main() {
  // Chain form: Fx inherits Dart's own .contains — the idiomatic name.
  print(fx([1, 2, 3]).contains(3)); // true
  print(fx([1, 2, 3]).contains(9)); // false

  // Data-first form keeps the FxTS name `includes` — there's no top-level
  // `contains` (it collides with package:test's matcher):
  print(includes(3, [1, 2, 3]));         // true
  print(fx(['a', 'b', 'c']).contains('b')); // true
}
