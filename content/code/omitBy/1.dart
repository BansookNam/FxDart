import 'package:fxdart/fxdart.dart';

void main() {
  final inventory = {'sword': 0, 'shield': 3, 'potion': 0, 'bow': 5};

  // Drop out-of-stock items:
  final inStock = omitBy((e) => e.$2 == 0, inventory);
  print(inStock); // {shield: 3, bow: 5}
}
