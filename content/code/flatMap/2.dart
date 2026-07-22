import 'package:fxdart/fxdart.dart';

void main() {
  final sentences = ['fx is lazy', 'dart is typed'];

  // TODO: use expand to split each sentence into words, producing one flat
  // list of words.
  final words = fx(sentences).map((s) => s).toList();

  print(words);
}
