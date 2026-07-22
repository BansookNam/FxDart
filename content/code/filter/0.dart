import 'package:fxdart/fxdart.dart';

void main() {
  // Data-first form:
  print(toList(where((a) => a % 2 == 0, [0, 1, 2, 3, 4, 5, 6])));
  // [0, 2, 4, 6]
  // FxTS alias: filter((a) => a % 2 == 0, ...) does the same thing.

  // Chain form, with proof of laziness -- the predicate only runs for the
  // elements actually pulled before take(3) is satisfied:
  var calls = 0;
  final result = fx(range(1000000))
      .where((a) {
        calls++;
        return a % 2 == 0;
      })
      .take(3)
      .toList();

  print(result);                   // [0, 2, 4]
  print('where ran $calls times'); // 5 -- not 1000000
}
