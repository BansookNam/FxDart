import 'package:fxdart/fxdart.dart';

void main() {
  // Data-first form:
  print(toList(map((a) => a * 2, [1, 2, 3]))); // [2, 4, 6]

  // Chain form, with proof of laziness:
  var calls = 0;
  final result = fx(range(1000000))
      .map((a) {
        calls++;
        return a * a;
      })
      .take(3)
      .toList();

  print(result);            // [0, 1, 4]
  print('map ran $calls times'); // 3 — not 1000000!
}
