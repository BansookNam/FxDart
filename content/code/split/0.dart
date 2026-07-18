import 'package:fxdart/fxdart.dart';

void main() {
  // split iterates an iterable of single characters, so pass a string split
  // into chars with the built-in String.split(''):
  print(split(',', 'a,b,c'.split(''))); // (a, b, c)

  // A trailing separator produces a trailing empty piece:
  print(split(',', 'a,b,'.split(''))); // (a, b, )
}
