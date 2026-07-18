import 'package:fxdart/fxdart.dart';

bool isEven(int n) => n % 2 == 0;

void main() {
  print(unless<int>(isEven, (n) => n + 1, 4)); // 4 (already even, unchanged)
  print(unless<int>(isEven, (n) => n + 1, 3)); // 4 (odd, callback applied)
}
