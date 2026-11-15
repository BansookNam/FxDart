import 'package:fxdart/fxdart.dart';

void main() {
  final temps = [12, 15, 11, 18, 17, 21];

  // TODO: the running maximum, one value per reading. Replace
  // scan(...).drop(1) with mapAccum and the same seed.
  final highs = fx(temps)
      .scan((int best, t) => t > best ? t : best, -273)
      .drop(1)
      .toList();

  print(highs); // should print: [12, 15, 15, 18, 18, 21]
}
