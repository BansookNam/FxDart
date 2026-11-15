import 'package:fxdart/fxdart.dart';

void main() {
  final dice = [6, 6, 20];

  // TODO: replace the loop with fxProduct(dice).
  var outcomes = 1;
  for (final sides in dice) {
    outcomes *= sides;
  }

  print('$outcomes outcomes'); // should print: 720 outcomes
}
