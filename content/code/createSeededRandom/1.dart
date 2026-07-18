import 'package:fxdart/fxdart.dart';

void main() {
  final random = createSeededRandom(2024);
  int roll() => (random() * 6).floor() + 1;

  print([for (var i = 0; i < 5; i++) roll()]); // same rolls every run

  // shuffle(iterable, seed) uses createSeededRandom internally:
  print(shuffle([1, 2, 3, 4, 5], 2024)); // same order every run
  print(shuffle([1, 2, 3, 4, 5], 2024)); // ...see?
}
