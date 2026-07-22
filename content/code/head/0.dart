import 'package:fxdart/fxdart.dart';

void main() {
  print(firstOrNull([10, 20, 30])); // 10
  print(firstOrNull(<int>[]));      // null

  // Sync chain: .firstOrNull is the inherited Iterable getter — no parens.
  print(fx(['a', 'b', 'c']).firstOrNull); // a

  // FxTS alias: head — the same operator.
  print(head([10, 20, 30])); // 10
}
