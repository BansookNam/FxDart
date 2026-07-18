import 'package:fxdart/fxdart.dart';

void main() {
  // Data-first form: seed first, then the combiner, then the iterable.
  print(fold<int, int>(100, (acc, a) => acc + a, [1, 2, 3])); // 106

  // Works on an empty iterable, unlike reduce:
  print(fold<int, int>(0, (acc, a) => acc + a, <int>[])); // 0

  // Chain form uses Dart's built-in Iterable.fold(initialValue, combine):
  final joined = fx(['a', 'b', 'c']).fold<String>('', (acc, a) => '$acc$a');
  print(joined); // abc
}
