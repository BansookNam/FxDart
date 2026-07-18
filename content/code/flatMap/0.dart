import 'package:fxdart/fxdart.dart';

void main() {
  // Data-first form: f MUST return an Iterable<B> -- same contract as
  // Iterable.expand.
  print(toArray(flatMap((a) => [a, a * 10], [1, 2, 3])));
  // [1, 10, 2, 20, 3, 30]

  // Chain form: split words into individual characters.
  final letters = fx(['ab', 'cd'])
      .flatMap((word) => word.split(''))
      .toArray();
  print(letters); // [a, b, c, d]
}
