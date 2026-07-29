import 'package:fxdart/fxdart.dart';

void main() {
  final nel = NonEmptyList.of(1, [2, 3]);
  print(nel); // [1, 2, 3]
  print(nel.head); // 1 — total: cannot throw, unlike List.first
  print(nel.tail); // [2, 3]
  print(nel.length); // 3

  // The only way to build one from a plain List is orNull — the emptiness
  // check happens exactly once, at the boundary:
  print(NonEmptyList.orNull(<int>[])); // null
  print(NonEmptyList.orNull([7, 8])); // [7, 8]

  // Nel is the short alias (Arrow's name):
  final Nel<String> tags = Nel.of('fp');
  print(tags.head); // fp
}
