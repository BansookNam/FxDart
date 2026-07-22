import 'package:fxdart/fxdart.dart';

void main() {
  // Data-first form: largest value, first element becomes the seed.
  // (Assigned to a local on purpose: inside print(...) Dart would fix the
  // type parameter to Object? from the context before looking at the list.)
  final largest = reduce((acc, a) => acc > a ? acc : a, [3, 7, 2, 9, 4]);
  print(largest); // 9

  // Chain form uses Dart's built-in Iterable.reduce (same contract):
  final total = fx([1, 2, 3, 4]).reduce((acc, a) => acc + a);
  print(total); // 10

  // Unseeded reduce throws on empty input:
  try {
    reduce((acc, a) => acc + a, <int>[]);
  } on StateError catch (e) {
    print('StateError: ${e.message}');
  }
}
