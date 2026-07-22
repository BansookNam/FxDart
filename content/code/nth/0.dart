import 'package:fxdart/fxdart.dart';

void main() {
  final letters = ['a', 'b', 'c', 'd'];
  print(elementAtOrNull(0, letters));  // a
  print(elementAtOrNull(2, letters));  // c
  print(elementAtOrNull(10, letters)); // null
  print(elementAtOrNull(-1, letters)); // null (negative indices are simply out of range)

  // Sync chain: .elementAtOrNull(i) is the inherited Iterable method.
  print(fx(letters).elementAtOrNull(2)); // c

  // FxTS alias: nth — the same operator.
  print(nth(2, letters)); // c
}
