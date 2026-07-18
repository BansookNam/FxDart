import 'package:fxdart/fxdart.dart';

void main() {
  print(head([10, 20, 30])); // 10
  print(head(<int>[]));      // null

  print(fx(['a', 'b', 'c']).head()); // a
}
