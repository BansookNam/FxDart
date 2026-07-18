import 'package:fxdart/fxdart.dart';

void main() {
  print(when<int>((n) => n < 0, (n) => -n, -5)); // 5
  print(when<int>((n) => n < 0, (n) => -n, 5));  // 5 (unchanged)
}
