import 'package:fxdart/fxdart.dart';

void main() {
  // scan: seeded running accumulation -- the seed is emitted first.
  print(toArray(scan((acc, a) => acc + a, 10, [1, 2, 3])));
  // [10, 11, 13, 16]

  // scan1: no seed -- the first element seeds the accumulator instead.
  print(toArray(scan1((acc, a) => acc > a ? acc : a, [3, 1, 4, 1, 5])));
  // [3, 3, 4, 4, 5] -- running max

  // Chain form (scan only -- scan1 has no chain method, use data-first):
  final running = fx([1, 2, 3]).scan((acc, a) => acc * a, 1).toArray();
  print(running); // [1, 1, 2, 6]

  // scan1 on an empty iterable yields nothing at all (no seed to emit):
  print(toArray(scan1((acc, a) => acc + a, <int>[]))); // []
}
