import 'package:fxdart/fxdart.dart';

void main() {
  // Data-first form: counts elements by pulling the whole pipeline.
  print(count(range(1000000).where((a) => a % 7 == 0))); // 142858

  // Sync chain: count is Dart's inherited .length getter — no parens.
  final n = fx([1, 2, 3, 4, 5, 6]).filter((a) => a.isEven).length;
  print(n); // 3

  // FxTS alias: size — the same operator.
  print(size([1, 2, 3])); // 3
}
