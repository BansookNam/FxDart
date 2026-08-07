import 'package:fxdart/fxdart.dart';

void main() {
  // The longest run at the END where the test passes, in source order.
  print(takeWhileRight((a) => a > 2, [1, 4, 2, 3, 4])); // (3, 4)

  // Empty as soon as the last element fails — an earlier run does not count.
  print(takeWhileRight((a) => a > 2, [3, 4, 1])); // ()

  final streak = fx([1, 0, 1, 1, 1]).takeWhileRight((a) => a == 1).toList();
  print(streak); // [1, 1, 1]
}
