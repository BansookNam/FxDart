import 'package:fxdart/fxdart.dart';

void main() {
  final parts = ['foo', 'bar', 'baz'];

  // TODO: use fold + add to concatenate all the parts into one string
  final joined = fxFold('', fxAdd, parts);

  print(joined); // foobarbaz
}
