import 'package:fxdart/fxdart.dart';

void main() {
  final deck = [1, 2, 3, 4, 5, 6, 7, 8];

  // No seed: a fresh, unpredictable order every run.
  print(shuffle(deck)); // e.g. [4, 7, 1, 8, 3, 6, 2, 5] — different every run

  // Same seed, same order — every time, on every machine.
  final a = shuffle(deck, 42);
  final b = shuffle(deck, 42);
  print(a); // [3, 8, 2, 1, 7, 6, 4, 5]
  print(a.toString() == b.toString()); // true

  // A different seed gives a different (still deterministic) order.
  final c = shuffle(deck, 7);
  print(a.toString() == c.toString()); // false
}
