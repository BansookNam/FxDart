import 'package:fxdart/fxdart.dart';

void main() {
  final prices = {'apple': 1000, 'pear': 1500};

  print(mapValues((p) => p * 2, prices)); // {apple: 2000, pear: 3000}
  print(mapKeys((k) => k.toUpperCase(), prices)); // {APPLE: 1000, PEAR: 1500}

  // The general form takes the whole (key, value) record — here it swaps
  // the two, inverting the map.
  print(mapEntries((e) => (e.$2, e.$1), prices)); // {1000: apple, 1500: pear}
}
