import 'package:fxdart/fxdart.dart';

void main() {
  final scores = [('ana', 91), ('kim', 78), ('lee', 85)];

  // unzip: one pass, two lists — lefts and rights.
  final (names, points) = fxUnzip(scores);
  print(names); // [ana, kim, lee]
  print(points); // [91, 78, 85]

  // Chain spelling: unzip closes a chain of pairs.
  final (passed, _) = fx(scores).filter((p) => p.$2 >= 80).unzip();
  print(passed); // [ana, lee]

  // The inverse of zip — truncated to the shorter side:
  final (letters, numbers) = fxUnzip(fxZip(['a', 'b', 'c'], [1, 2]));
  print('$letters $numbers'); // [a, b] [1, 2]

  // Empty in, two empty lists out:
  final (l, r) = fxUnzip(<(String, int)>[]);
  print('$l $r'); // [] []
}
