import 'package:fxdart/fxdart.dart';

void main() {
  final s = 'a👍b';
  print(s.split('').length);     // 4 — naive split breaks the emoji apart
  print(unicodeToArray(s));      // [a, 👍, b]
  print(unicodeToArray(s).length); // 3 — correct character count
}
