import 'package:fxdart/fxdart.dart';

void main() {
  final words = ['pear', 'apple', 'fig'];

  // TODO: sort `words` using identity as the key function
  final sorted = fx(words).sortBy(identity).toList();

  print(sorted); // [apple, fig, pear]
}
