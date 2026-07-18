import 'package:fxdart/fxdart.dart';

String reverseUnicode(String s) => unicodeToArray(s).reversed.join();

void main() {
  print(reverseUnicode('a👍b')); // b👍a

  final counts = countBy(identity, unicodeToArray('aabb👍👍'));
  print(counts); // {a: 2, b: 2, 👍: 2}
}
