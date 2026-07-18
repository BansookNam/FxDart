import 'package:fxdart/fxdart.dart';

void main() {
  // Data-first form:
  print(sum([1, 2, 3, 4])); // 10

  // Chain form (Fx<num> extension), pulls the lazy pipeline:
  final total = fx([1, 2, 3, 4, 5])
      .filter((a) => a.isOdd)
      .map((a) => a * 10)
      .sum();
  print(total); // 90

  // Empty iterable sums to 0 (the fold seed), unlike min/max:
  print(sum(<num>[])); // 0
}
