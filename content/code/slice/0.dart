import 'package:fxdart/fxdart.dart';

void main() {
  // Note the argument order: the iterable sits in the MIDDLE.
  print(slice(2, [10, 20, 30, 40, 50], 4)); // (30, 40)

  // Omit `end` to take everything from `start` onward:
  print(slice(2, [10, 20, 30, 40, 50])); // (30, 40, 50)

  // Chain form takes only start/end (the receiver is the iterable):
  final result = fx([10, 20, 30, 40, 50]).slice(1, 3).toArray();
  print(result); // [20, 30]
}
