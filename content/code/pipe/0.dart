import 'package:fxdart/fxdart.dart';

void main() {
  // pipe is dynamically typed: fns is a List<Function>, each step receives
  // whatever `dynamic` the previous step returned.
  final result = pipe([1, 2, 3, 4, 5], [
    (Iterable<int> a) => fxMap((n) => n + 10, a),
    (Iterable<int> a) => fxFilter((n) => n % 2 == 0, a),
    fxToList,
  ]);

  print(result); // [12, 14]
  print(result.runtimeType); // List<dynamic> — pipe() erased the element type
}
