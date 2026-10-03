import 'package:fxdart/fxdart.dart';

void main() {
  print(fxToList(fxRepeat(3, 'x')));  // [x, x, x]
  print(fxToList(fxRepeat(0, 'x')));  // [] — n=0 yields nothing
  print(fx(fxRepeat(4, '-')).join()); // ----
}
