import 'package:fxdart/fxdart.dart';

void main() {
  // A reusable "total the lengths" reducer, reused across two different lists:
  final totalLength = reduceLazy<String, int>((acc, s) => acc + s.length, 0);

  for (final words in [
    ['fx', 'dart', 'is', 'lazy'],
    ['a', 'bb'],
  ]) {
    print(totalLength(words));
  }
}
