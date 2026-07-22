import 'package:fxdart/fxdart.dart';

void main() {
  final s = 'go🚀go';

  // TODO: count how many user-perceived characters are in `s`
  final count = unicodeToList(s).length;

  print(count); // 5
}
