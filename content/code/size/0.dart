import 'package:fxdart/fxdart.dart';

void main() {
  // Data-first form: counts elements by pulling the whole pipeline.
  print(size(range(1000000).where((a) => a % 7 == 0))); // 142858

  // Chain form:
  final count = fx([1, 2, 3, 4, 5, 6]).filter((a) => a.isEven).size();
  print(count); // 3
}
