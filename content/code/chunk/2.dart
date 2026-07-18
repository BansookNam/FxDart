import 'package:fxdart/fxdart.dart';

void main() {
  final cards = ['A', 'K', 'Q', 'J', '10', '9', '8'];

  // TODO: deal the cards into hands of 3
  final hands = fx(cards).toArray();

  print(hands);
}
