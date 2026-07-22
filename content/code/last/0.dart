import 'package:fxdart/fxdart.dart';

void main() {
  print(lastOrNull([1, 2, 3])); // 3
  print(lastOrNull(<int>[]));   // null

  // Sync chain: .lastOrNull is the inherited getter — no parens, and null-safe.
  print(fx(<int>[]).lastOrNull); // null

  // The trap is the neighboring .last getter (no "OrNull"): throws on empty.
  try {
    fx(<int>[]).last;
  } on StateError catch (e) {
    print('Iterable.last threw: $e');
  }

  // FxTS alias: last — the same operator.
  print(last([1, 2, 3])); // 3
}
