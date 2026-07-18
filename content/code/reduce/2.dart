import 'package:fxdart/fxdart.dart';

void main() {
  final words = ['fx', 'dart', 'lazy', 'pipeline', 'go'];

  // TODO: use reduce to find the LONGEST word in the list.
  final longest = reduce<String>((acc, a) => acc, words);

  print(longest);
}
