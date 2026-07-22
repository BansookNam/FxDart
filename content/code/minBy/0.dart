import 'package:fxdart/fxdart.dart';

void main() {
  final words = ['banana', 'fig', 'apple'];

  // Data-first form: the element with the smallest key, in one O(n) walk.
  print(minBy((String w) => w.length, words)); // fig

  // Chain form:
  print(fx(words).minBy((w) => w.length)); // fig

  // Empty input returns null (like head/last), not a sentinel:
  print(minBy((int n) => n, <int>[])); // null

  // Ties keep the FIRST element encountered:
  print(minBy((String w) => w.length, ['aa', 'bb'])); // aa
}
