import 'package:fxdart/fxdart.dart';

void main() {
  final lines = List.generate(5, (i) => 'line $i\n');

  // TODO: replace the fold with fxSumStrings(lines).
  final text = fxFold<String, String>('', (acc, s) => acc + s, lines);

  print(text.length); // should print: 35
}
