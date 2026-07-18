import 'package:fxdart/fxdart.dart';

void main() {
  final List<int?> withGaps = [1, null, 2, null, 3];

  // Data-first form. The input element type is int?; the output is
  // Iterable<int> -- compact narrows the type, not just the values.
  final Iterable<int> tightened = compact(withGaps);
  print(toArray(tightened)); // [1, 2, 3]

  // No chain method exists for compact -- call it directly, or wrap with
  // fx(...) to keep chaining afterward.
  final result = fx(compact(withGaps)).map((a) => a * 10).toArray();
  print(result); // [10, 20, 30]
}
