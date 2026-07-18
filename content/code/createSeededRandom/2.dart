import 'package:fxdart/fxdart.dart';

void main() {
  final deck = ['A', 'K', 'Q', 'J', '10', '9', '8', '7'];

  // TODO: shuffle the deck twice with the same seed and take 3 cards each
  final hand1 = fx(shuffle(deck, 99)).take(3).toArray();
  final hand2 = fx(shuffle(deck, 99)).take(3).toArray();

  print(hand1);
  print(hand2); // identical to hand1
}
