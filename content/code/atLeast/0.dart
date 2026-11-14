import 'package:fxdart/fxdart.dart';

void main() {
  final fish = ['tetra', 'guppy', 'tetra', 'betta', 'tetra'];

  // "Is there a school?" — two of a kind is enough.
  print(fx(fish).atLeast(2, (f) => f == 'tetra')); // true
  print(fxAtLeast(2, (String f) => f == 'betta', fish)); // false

  // It stops at the nth match: only 0, 1, 2, 3 are tested here.
  var tested = 0;
  final found = fxAtLeast(2, (int n) {
    tested++;
    return n.isOdd;
  }, fxRange(1000000));
  print('$found after $tested tests'); // true after 4 tests
}
