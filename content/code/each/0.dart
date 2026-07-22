import 'package:fxdart/fxdart.dart';

void main() {
  // Data-first form: run f for side effects, get nothing back.
  forEach((a) => print('data-first: $a'), [1, 2, 3]);

  // Chain form (inherited from Iterable). FxTS alias: each is the same op.
  fx(['a', 'b', 'c']).forEach((a) => print('chain: $a'));
}
