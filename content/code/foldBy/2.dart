import 'package:fxdart/fxdart.dart';

void main() {
  final words = ['fig', 'kiwi', 'fx', 'plum', 'go', 'date'];

  // TODO: build {firstLetter: totalLettersUnderThatKey}.
  // Expected: {f: 5, k: 4, p: 4, g: 2, d: 4}
  final totals = foldBy((String w) => w[0], 0, (n, w) => n + 1, words);

  print(totals);
}
