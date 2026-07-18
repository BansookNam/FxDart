import 'package:fxdart/fxdart.dart';

void main() {
  // Data-first form: reject keeps everything filter would drop.
  print(toArray(reject((a) => a % 2 == 0, [0, 1, 2, 3, 4, 5, 6])));
  // [1, 3, 5]

  // Chain form:
  final result = fx(['ok', 'error', 'ok', 'timeout'])
      .reject((s) => s == 'ok')
      .toArray();
  print(result); // [error, timeout]
}
