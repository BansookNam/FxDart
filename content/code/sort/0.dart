import 'package:fxdart/fxdart.dart';

void main() {
  final original = [5, 2, 8, 1, 9];

  // Data-first form: always returns a NEW list, unlike JS/FxTS array.sort
  // which mutates in place.
  final sorted = sort<int>((a, b) => a.compareTo(b), original);
  print(sorted); // [1, 2, 5, 8, 9]
  print(original); // [5, 2, 8, 1, 9]  <- untouched

  // toSorted is just an alias of sort, kept for FxTS familiarity:
  print(toSorted<int>((a, b) => b.compareTo(a), original)); // [9, 8, 5, 2, 1]

  // Chain form: .sort(f) returns another Fx (still lazy on paper), so pull
  // it with .toArray() to get a concrete List:
  final chained = fx(original).sort((a, b) => a.compareTo(b)).toArray();
  print(chained); // [1, 2, 5, 8, 9]
}
