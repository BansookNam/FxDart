import 'package:fxdart/fxdart.dart';

void main() {
  // Data-first form: whereNot keeps everything where would drop.
  print(toList(whereNot((a) => a % 2 == 0, [0, 1, 2, 3, 4, 5, 6])));
  // [1, 3, 5]
  // FxTS alias: reject((a) => a % 2 == 0, ...) does the same thing.

  // Chain form:
  final result = fx(['ok', 'error', 'ok', 'timeout'])
      .whereNot((s) => s == 'ok')
      .toList();
  print(result); // [error, timeout]
}
