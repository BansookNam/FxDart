import 'package:fxdart/fxdart.dart';

void main() {
  // Data-first form. IMPORTANT: the argument order is NOT symmetric --
  // difference(iterable1, iterable2) returns the elements OF iterable2
  // that do NOT occur in iterable1 (duplicates in iterable2 collapse too).
  final owned = [1, 2, 3];
  final wishlist = [2, 3, 4, 4, 5];

  print(toArray(difference(owned, wishlist)));
  // [4, 5] -- wishlist items you don't already own

  // Swap the arguments and the result is completely different:
  print(toArray(difference(wishlist, owned)));
  // [1] -- owned items not on the wishlist

  // No chain method exists for difference -- call it data-first.
}
