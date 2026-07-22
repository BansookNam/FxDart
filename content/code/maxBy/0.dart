import 'package:fxdart/fxdart.dart';

void main() {
  final words = ['fig', 'banana', 'apple'];

  // Data-first form: the element with the largest key, in one O(n) walk.
  print(maxBy((String w) => w.length, words)); // banana

  // Chain form:
  print(fx(words).maxBy((w) => w.length)); // banana

  // Empty input returns null (like head/last), not a sentinel:
  print(maxBy((int n) => n, <int>[])); // null

  // Ties keep the FIRST element encountered:
  print(maxBy((String w) => w.length, ['aa', 'bb'])); // aa
}
