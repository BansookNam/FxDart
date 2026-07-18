import 'package:fxdart/fxdart.dart';

void main() {
  final nums = [4, 8, 15, 16, 23, 42];
  print(findIndex((a) => a > 15, nums));      // 3
  print(fx(nums).findIndex((a) => a > 100));  // -1
}
