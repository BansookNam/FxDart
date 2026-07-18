import 'package:fxdart/fxdart.dart';

void main() {
  // A Map isn't an Iterable itself, so wrap entries(map) with fx() to chain
  // FxDart operators over its (key, value) pairs.
  final inventory = {'apples': 4, 'bananas': 0, 'cherries': 12};

  final inStock = fx(entries(inventory))
      .filter((e) => e.$2 > 0)
      .map((e) => '${e.$1}: ${e.$2}')
      .toArray();

  print(inStock); // [apples: 4, cherries: 12]
}
