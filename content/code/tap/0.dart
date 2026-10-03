import 'package:fxdart/fxdart.dart';

void main() {
  final a = fxTap((v) => print('side effect: $v'), 42);
  print(a); // 42
}
