import 'package:fxdart/fxdart.dart';

void main() {
  final samples = [3, 7, 4, 0, 0, 0];

  // TODO: drop the trailing zeros and keep the rest.
  final trimmed = fx(samples).dropWhileRight((a) => a == 0).toList();

  print(trimmed); // [3, 7, 4]
}
