import 'package:fxdart/fxdart.dart';

bool isVowel(String c) => 'aeiou'.contains(c);

void main() {
  final letters = ['a', 'b', 'c', 'e', 'd'];

  // TODO: use negate(isVowel) to keep only the consonants
  final consonants = fx(letters).filter(negate(isVowel)).toArray();

  print(consonants); // [b, c, d]
}
