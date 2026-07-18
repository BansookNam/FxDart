import 'package:fxdart/fxdart.dart';

void main() {
  final words = ['apple', 'banana', 'avocado', 'blueberry', 'cherry'];

  // Data-first form: key selector, then the iterable.
  final byFirstLetter = groupBy((w) => w[0], words);
  print(byFirstLetter);
  // {a: [apple, avocado], b: [banana, blueberry], c: [cherry]}

  // Chain form:
  final byParity = fx([1, 2, 3, 4, 5, 6]).groupBy((a) => a.isEven ? 'even' : 'odd');
  print(byParity); // {odd: [1, 3, 5], even: [2, 4, 6]}
}
