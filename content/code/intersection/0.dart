import 'package:fxdart/fxdart.dart';

void main() {
  // Data-first form. Same argument-order rule as difference: the result
  // comes FROM iterable2, in iterable2's order, keeping only elements ALSO
  // found in iterable1.
  final inStock = {'mouse', 'keyboard', 'monitor'};
  final wishlist = ['monitor', 'mouse', 'headphones', 'mouse'];

  print(toArray(intersection(inStock, wishlist)));
  // [monitor, mouse] -- wishlist's order, deduped, filtered to in-stock items

  // Swap the arguments: now the ORDER comes from inStock instead.
  print(toArray(intersection(wishlist, inStock)));
  // [mouse, monitor] -- inStock's own iteration order this time
}
