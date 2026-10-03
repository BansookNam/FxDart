import 'package:fxdart/fxdart.dart';

void main() {
  print(fxWhen<int>((n) => n < 0, (n) => -n, -5)); // 5
  print(fxWhen<int>((n) => n < 0, (n) => -n, 5));  // 5 (unchanged)
}
