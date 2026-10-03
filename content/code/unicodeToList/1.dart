import 'package:fxdart/fxdart.dart';

String reverseUnicode(String s) => unicodeToList(s).reversed.join();

void main() {
  print(reverseUnicode('a👍b')); // b👍a

  final counts = fxCountBy(fxIdentity, unicodeToList('aabb👍👍'));
  print(counts); // {a: 2, b: 2, 👍: 2}
}
