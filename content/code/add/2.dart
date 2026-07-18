import 'package:fxdart/fxdart.dart';

void main() {
  final parts = ['foo', 'bar', 'baz'];

  // TODO: use fold + add to concatenate all the parts into one string
  final joined = fold('', add, parts);

  print(joined); // foobarbaz
}
