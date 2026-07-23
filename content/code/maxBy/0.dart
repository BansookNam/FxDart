import 'package:fxdart/fxdart.dart';

void main() {
  final words = ['fig', 'banana', 'apple'];

  // Data-first form: the element with the largest key, in one O(n) walk.
  // (The key comes first, so name the element type — maxBy<String> — since
  // inference can't read it back from the callback.)
  print(maxBy<String>((w) => w.length, words)); // banana

  // Chain form: the element type is already known, so no annotation needed.
  print(fx(words).maxBy((w) => w.length)); // banana

  // Empty input returns null (like head/last), not a sentinel:
  print(maxBy<int>((n) => n, <int>[])); // null

  // Ties keep the FIRST element encountered:
  print(maxBy<String>((w) => w.length, ['aa', 'bb'])); // aa
}
