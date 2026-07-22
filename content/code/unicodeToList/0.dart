import 'package:fxdart/fxdart.dart';

void main() {
  final s = 'a👍b';
  print(s.split('').length);     // 4 — naive split breaks the emoji apart
  print(unicodeToList(s));      // [a, 👍, b]
  print(unicodeToList(s).length); // 3 — correct character count
}
