import 'package:fxdart/fxdart.dart';

void main() {
  // Data-first form returns a (pass, fail) record -- access with .$1/.$2.
  final result = partition((a) => a.isEven, [1, 2, 3, 4, 5, 6]);
  print(result.$1); // [2, 4, 6]  (pass: predicate true)
  print(result.$2); // [1, 3, 5]  (fail: predicate false)

  // Chain form, destructured directly:
  final (evens, odds) = fx([1, 2, 3, 4, 5, 6]).partition((a) => a.isEven);
  print(evens); // [2, 4, 6]
  print(odds); // [1, 3, 5]
}
