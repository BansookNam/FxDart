import 'package:fxdart/fxdart.dart';

void main() {
  // Unlike takeWhile, the matching element IS included:
  print(takeUntilInclusive((a) => a == 3, [1, 2, 3, 4, 5])); // (1, 2, 3)

  final result =
      fx(['a', 'b', 'STOP', 'c']).takeUntilInclusive((a) => a == 'STOP').toList();
  print(result); // [a, b, STOP]

  // Deprecated alias kept for FxTS parity:
  // ignore: deprecated_member_use
  print(takeUntil((a) => a == 3, [1, 2, 3, 4])); // (1, 2, 3)
}
