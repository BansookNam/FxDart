import 'package:fxdart/fxdart.dart';

void main() {
  final inventory = [3, 0, 7, 0, 5, 0, 9];

  // TODO: count how many entries are OUT OF STOCK (value == 0).
  // Hint: on the sync chain, count is the inherited .length getter — no parens.
  final n = fx(inventory).length;

  print(n);
}
