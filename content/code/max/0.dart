import 'package:fxdart/fxdart.dart';

void main() {
  // Data-first form:
  print(max([5, 2, 8, 1, 9])); // 9

  // Chain form:
  print(fx([5, 2, 8, 1, 9]).max()); // 9

  // Empty input returns -infinity (the fold seed), the mirror image of min:
  print(max(<num>[])); // -Infinity

  // NaN poisons max too:
  print(max([1, 2, double.nan, 4])); // NaN
}
