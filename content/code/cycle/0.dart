import 'package:fxdart/fxdart.dart';

void main() {
  // cycle repeats its source FOREVER — always pair it with take (or some
  // other bound) or the pipeline will never finish.
  final result = fx([1, 2, 3]).cycle().take(7).toList();
  print(result); // [1, 2, 3, 1, 2, 3, 1]

  // Data-first form is the same:
  print(fxToList(fxTake(5, fxCycle(['a', 'b'])))); // [a, b, a, b, a]

  // An empty source cycles to nothing, rather than hanging:
  print(fxToList(fxTake(3, fxCycle(<int>[])))); // []
}
