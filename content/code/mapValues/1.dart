import 'package:fxdart/fxdart.dart';

void main() {
  // On a collision the LAST key wins, exactly as in a map literal.
  print(mapKeys((k) => k[0], {'ax': 1, 'ay': 2, 'b': 3})); // {a: 2, b: 3}

  // pickBy is the key-aware filter: its predicate takes the same record, so
  // ignoring one half is how you filter by the other.
  final stock = {'apple': 0, 'pear': 4, 'plum': 7};
  final inStock = pickBy((e) => e.$2 > 0, stock);
  print(mapValues((n) => '$n left', inStock)); // {pear: 4 left, plum: 7 left}
}
