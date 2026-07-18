import 'package:fxdart/fxdart.dart';

void main() {
  final scores = [55, 72, 88, 40, 91, 63];

  // TODO: build a lazy chain that keeps scores >= 60, doubles them as bonus
  // points, and takes only the first 2 — then run it with toArray().
  final bonus = fx(scores)
      .filter((s) => s >= 60)
      .map((s) => s * 2)
      .take(2)
      .toArray();

  print(bonus); // [144, 176]
}
