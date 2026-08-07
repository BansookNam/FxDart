import 'package:fxdart/fxdart.dart';

void main() {
  final rows = ['alpha', 'beta', 'gamma'];

  print(fx(rows).mapWithIndex((row, i) => '${i + 1}. $row').toList());
  // [1. alpha, 2. beta, 3. gamma]

  // The same result through zipWithIndex: a record per element, and a
  // callback reading $1/$2 instead of named parameters.
  print(fx(rows).zipWithIndex().map((p) => '${p.$1 + 1}. ${p.$2}').toList());
  // [1. alpha, 2. beta, 3. gamma]
}
