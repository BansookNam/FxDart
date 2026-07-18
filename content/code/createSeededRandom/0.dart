import 'package:fxdart/fxdart.dart';

void main() {
  final a = createSeededRandom(42);
  final b = createSeededRandom(42);
  final c = createSeededRandom(7);

  print([a(), a(), a()]); // deterministic triple
  print([b(), b(), b()]); // identical to a's
  print([c(), c(), c()]); // different seed, different triple
}
