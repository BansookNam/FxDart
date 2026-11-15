import 'package:fxdart/fxdart.dart';

void main() {
  final raw = ['12', 'n/a', '7', '', '30'];

  // mapNotNull: the callback transforms AND selects — null means skip.
  print(mapNotNull(int.tryParse, raw)); // (12, 7, 30)

  // The same values, spelled as two lazy stages:
  print(fxCompact(fxMap(int.tryParse, raw))); // (12, 7, 30)

  // Chain spelling:
  print(fx(raw).mapNotNull(int.tryParse).sum()); // 49

  // firstNotNullOf: the first non-null projection, then it stops.
  print(firstNotNullOf(int.tryParse, ['x', '', '42', '5'])); // 42
  print(fx(['x', 'y']).firstNotNullOf(int.tryParse)); // null

  // find returns the element; firstNotNullOf returns the projection.
  print(fx(raw).find((s) => int.tryParse(s) != null)); // 12  (a String)
  print(fx(raw).firstNotNullOf(int.tryParse)); // 12  (an int)
}
