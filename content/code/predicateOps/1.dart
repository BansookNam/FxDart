import 'package:fxdart/fxdart.dart';

bool isEven(int n) => n % 2 == 0;

void main() {
  // contramap moves a predicate onto another type by mapping the ARGUMENT
  // before the test — map for the input rather than the result.
  final hasEvenLength = isEven.contramap<String>((s) => s.length);
  print(fx(['a', 'ab', 'abc', 'abcd']).filter(hasEvenLength).toList());
  // [ab, abcd]

  // and/or short-circuit, so the right-hand predicate is not always called.
  var calls = 0;
  bool counted(int n) {
    calls++;
    return true;
  }

  print(isEven.and(counted)(3)); // false
  print(calls); // 0
}
