import 'package:fxdart/fxdart.dart';

void main() {
  // Data-first form: f MUST return an Iterable<B> -- same contract as
  // Iterable.expand.
  print(toList(expand((a) => [a, a * 10], [1, 2, 3])));
  // [1, 10, 2, 20, 3, 30]
  // FxTS alias: flatMap((a) => [a, a * 10], [1, 2, 3]) is identical.

  // Chain form: split words into individual characters.
  final letters = fx(['ab', 'cd'])
      .expand((word) => word.split(''))
      .toList();
  print(letters); // [a, b, c, d]
}
