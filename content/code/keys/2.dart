import 'package:fxdart/fxdart.dart';

void main() {
  final inventory = {'apples': 4, 'bananas': 0, 'cherries': 12};

  // TODO: use keys() and sort() to get an alphabetically sorted list of
  // the inventory's item names.
  final names = fx(keys(inventory)).sort((a, b) => a.compareTo(b)).toArray();

  print(names); // [apples, bananas, cherries]
}
