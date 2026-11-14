import 'package:fxdart/fxdart.dart';

void main() {
  var writes = 0;
  void save(int coins) => writes++;

  // TODO: wrap save with fxOnChange so an unchanged coin count
  // is not written again.
  final onCoins = save;

  for (final c in [5, 5, 5, 6, 6, 7]) {
    onCoins(c);
  }
  print('writes: $writes'); // should print: writes: 3
}
