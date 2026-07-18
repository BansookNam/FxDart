import 'package:fxdart/fxdart.dart';

void main() {
  // The matching element is dropped too, unlike dropWhile which keeps it:
  print(dropUntil((a) => a == 3, [1, 2, 3, 4, 5])); // (4, 5)

  final result =
      fx(['a', 'b', 'STOP', 'c', 'd']).dropUntil((a) => a == 'STOP').toArray();
  print(result); // [c, d]
}
