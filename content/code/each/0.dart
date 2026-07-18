import 'package:fxdart/fxdart.dart';

void main() {
  // Data-first form: run f for side effects, get nothing back.
  each((a) => print('data-first: $a'), [1, 2, 3]);

  // Chain form:
  fx(['a', 'b', 'c']).each((a) => print('chain: $a'));
}
