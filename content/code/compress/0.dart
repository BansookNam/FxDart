import 'package:fxdart/fxdart.dart';

void main() {
  // Data-first form: keeps iterable[i] wherever selectors[i] is true.
  print(fxToList(fxCompress([true, false, true, false], ['a', 'b', 'c', 'd'])));
  // [a, c]

  // If selectors is shorter than iterable, extra iterable elements are
  // dropped (zip -- which compress is built on -- stops at the shorter one):
  print(fxToList(fxCompress([true, false], ['a', 'b', 'c', 'd'])));
  // [a]

  // No chain method exists for compress -- call it directly.
}
