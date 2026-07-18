import 'package:fxdart/fxdart.dart';

void main() {
  print(some((a) => a > 10, [1, 2, 3])); // false
  print(some((a) => a > 2, [1, 2, 3]));  // true
  print(some((a) => true, <int>[]));     // false — nothing to satisfy it

  var checked = 0;
  final found = fx([1, 2, 3, 4]).peek((_) => checked++).some((a) => a == 2);
  print(found);               // true
  print('checked $checked');  // checked 2
}
