import 'package:fxdart/fxdart.dart';

void main() {
  print(fxSumStrings(['fx', 'dart', '!'])); // fxdart!
  print(fxSumStrings(<String>[]).isEmpty); // true

  // The same answer the fold gives — fxSumStrings is just faster:
  final parts = ['a', 'b', 'c'];
  print(fxFold<String, String>('', (acc, s) => acc + s, parts)); // abc
  print(fxSumStrings(parts)); // abc

  // It takes one argument, so it slots straight into pipe:
  print(pipe(['x', 'y', 'z'], [fxSumStrings])); // xyz
}
