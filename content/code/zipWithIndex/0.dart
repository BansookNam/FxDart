import 'package:fxdart/fxdart.dart';

void main() {
  print(indexed(['a', 'b', 'c'])); // ((0, a), (1, b), (2, c))

  // Sync chain: .indexed is the inherited Iterable getter — no parens.
  final result = fx(['x', 'y', 'z']).indexed.toList();
  print(result); // [(0, x), (1, y), (2, z)]

  // FxTS alias: zipWithIndex — the same operator.
  print(zipWithIndex(['a', 'b', 'c'])); // ((0, a), (1, b), (2, c))
}
