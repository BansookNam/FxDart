import 'package:fxdart/fxdart.dart';

void main() {
  // Data-first form: peek runs f for its side effect and yields a untouched.
  final seen = <int>[];
  final result = toArray(peek((a) => seen.add(a), [1, 2, 3]));
  print(result); // [1, 2, 3] -- same values in, same values out
  print(seen);   // [1, 2, 3]

  // Chain form: a debug print dropped into the middle of a pipeline,
  // without disturbing the values flowing through it.
  final total = fx([1, 2, 3, 4])
      .map((a) => a * a)
      .peek((a) => print('squared: $a'))
      .fold(0, (acc, a) => acc + a);
  print('total: $total'); // total: 30
}
