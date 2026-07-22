import 'package:fxdart/fxdart.dart';

int clamp(int max, int value) => value > max ? max : value;

void main() {
  // TODO: derive clampTo100 from clamp with .curried
  final clampTo100 = clamp.curried(100);

  print(fx([50, 99, 150, 300]).map(clampTo100).toList());
  // [50, 99, 100, 100]
}
