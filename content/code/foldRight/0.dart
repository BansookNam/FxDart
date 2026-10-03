import 'package:fxdart/fxdart.dart';

void main() {
  // fold nests from the left, foldRight from the right.
  // (Both need the explicit <A, Acc>, the same way Dart's own fold does —
  // an untyped accumulator lambda infers Acc as Object?.)
  print(fxFold<int, int>(0, (acc, a) => acc - a, [1, 2, 3]));
  // ((0 - 1) - 2) - 3 == -6

  print(fxFoldRight<int, int>(0, (acc, a) => a - acc, [1, 2, 3]));
  // 1 - (2 - (3 - 0)) == 2

  // The reducer keeps fold's (acc, element) shape, so one callback works
  // with either direction.
  print(fx(['a', 'b', 'c']).foldRight('nil', (acc, c) => '($c . $acc)'));
  // (a . (b . (c . nil)))
}
