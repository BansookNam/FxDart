import 'package:fxdart/fxdart.dart';

void main() {
  // consume pulls values through the chain (running peek/mapEffect for
  // their side effects) but throws the results away — no List is built.
  var seen = <int>[];
  fx(range(1000000))
      .peek((a) => seen.add(a))
      .consume(5); // only pull 5, even though range has a million

  print(seen); // [0, 1, 2, 3, 4]

  // consume() with no argument drains the whole (finite!) iterable.
  var count = 0;
  fx([1, 2, 3, 4]).peek((_) => count++).consume();
  print('count: $count'); // 4
}
