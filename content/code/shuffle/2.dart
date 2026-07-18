import 'package:fxdart/fxdart.dart';

void main() {
  final players = ['ann', 'bo', 'cara', 'di', 'eli'];

  // TODO: pass a seed (e.g. 7) to shuffle() so this turn order is
  // reproducible across app restarts instead of random every time.
  final turnOrder = shuffle(players);

  print(turnOrder.length); // 5
  print(List.of(turnOrder)..sort()); // [ann, bo, cara, di, eli]
}
