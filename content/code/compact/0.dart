import 'package:fxdart/fxdart.dart';

void main() {
  final List<int?> withGaps = [1, null, 2, null, 3];

  // Data-first form. The input element type is int?; the output is
  // Iterable<int> -- nonNulls narrows the type, not just the values.
  final Iterable<int> tightened = nonNulls(withGaps);
  print(toList(tightened)); // [1, 2, 3]
  // FxTS alias: compact(withGaps) does the same thing.

  // On the sync chain, .nonNulls is an inherited Iterable getter (no parens).
  // It returns a plain Iterable<int>, so wrap with fx(...) to keep chaining.
  final result = fx(fx(withGaps).nonNulls).map((a) => a * 10).toList();
  print(result); // [10, 20, 30]
}
