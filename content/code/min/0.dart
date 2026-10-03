import 'package:fxdart/fxdart.dart';

void main() {
  // Data-first form:
  print(fxMin([5, 2, 8, 1, 9])); // 1

  // Chain form:
  print(fx([5, 2, 8, 1, 9]).min()); // 1

  // FxTS semantics: empty input returns +infinity (the fold seed), not null:
  print(fxMin(<num>[])); // Infinity

  // A single NaN poisons the whole result, just like FxTS:
  print(fxMin([1, 2, double.nan, 4])); // NaN
}
