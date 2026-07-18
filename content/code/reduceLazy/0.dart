import 'package:fxdart/fxdart.dart';

void main() {
  // reduceLazy(f, seed) builds a reusable reducer: Iterable<A> -> Acc.
  final sumAll = reduceLazy<int, int>((acc, a) => acc + a, 0);

  print(sumAll([1, 2, 3])); // 6
  print(sumAll([10, 20])); // 30

  // Handy inside a chain via `.to(...)`, since it just needs an Iterable<A>:
  final total = fx([4, 5, 6]).to(sumAll);
  print(total); // 15
}
