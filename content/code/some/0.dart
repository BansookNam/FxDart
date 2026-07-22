import 'package:fxdart/fxdart.dart';

void main() {
  print(any((a) => a > 10, [1, 2, 3])); // false
  print(any((a) => a > 2, [1, 2, 3]));  // true
  print(any((a) => true, <int>[]));     // false — nothing to satisfy it

  // FxTS alias: some is the same operator.
  var checked = 0;
  final found = fx([1, 2, 3, 4]).peek((_) => checked++).any((a) => a == 2);
  print(found);               // true
  print('checked $checked');  // checked 2
}
