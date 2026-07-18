import 'package:fxdart/fxdart.dart';

void main() {
  // Data-first form:
  print(toArray(map((a) => a * 2, [1, 2, 3]))); // [2, 4, 6]

  // Chain form: toArray() is the terminal op that finally pulls values.
  var calls = 0;
  final result = fx(range(1000000))
      .map((a) {
        calls++;
        return a;
      })
      .take(3)
      .toArray();

  print(result);       // [0, 1, 2]
  print('calls: $calls'); // 3 — toArray only pulled what take(3) allowed
}
